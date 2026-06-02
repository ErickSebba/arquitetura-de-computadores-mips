library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Unidade de Controle baseada em FSM
-- Decodifica instrucao MIPS Tipo-R e coordena ROM, ULA e RAM
entity control_unit is
    port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        start        : in  std_logic;
        instruction  : in  std_logic_vector(31 downto 0);
        rom_data_in  : in  std_logic_vector(31 downto 0);
        rom_addr     : out std_logic_vector(4 downto 0);
        ram_addr     : out std_logic_vector(4 downto 0);
        ram_we       : out std_logic;
        reg_a_to_ula : out std_logic_vector(31 downto 0);
        done         : out std_logic
    );
end entity;

architecture rtl of control_unit is

    -- Estados da FSM conforme especificacao
    type state_type is (IDLE, FETCH_A, FETCH_B, STORE_RAM, FINISHED);
    signal state : state_type := IDLE;

    -- Registrador interno para guardar o operando A (rs)
    signal reg_a_internal : std_logic_vector(31 downto 0) := (others => '0');

    -- Campos decodificados da instrucao MIPS Tipo-R
    -- instruction[31:26] = op     (deve ser "000000" para Tipo-R)
    -- instruction[25:21] = rs     (endereco operando A na ROM)
    -- instruction[20:16] = rt     (endereco operando B na ROM)
    -- instruction[15:11] = rd     (endereco destino na RAM)
    -- instruction[10:6]  = shamt  (nao usado)
    -- instruction[5:0]   = funct  (operacao da ULA)
    alias rs    : std_logic_vector(4 downto 0) is instruction(25 downto 21);
    alias rt    : std_logic_vector(4 downto 0) is instruction(20 downto 16);
    alias rd    : std_logic_vector(4 downto 0) is instruction(15 downto 11);

begin

    -- Processo sequencial: transicao de estados e registradores
    process(clk, reset)
    begin
        if reset = '1' then
            state          <= IDLE;
            reg_a_internal <= (others => '0');

        elsif rising_edge(clk) then
            case state is

                -- IDLE: aguarda o pulso de start
                when IDLE =>
                    if start = '1' then
                        state <= FETCH_A;
                    end if;

                -- FETCH_A: envia rs para ROM; na proxima borda captura dado em reg_a_internal
                when FETCH_A =>
                    reg_a_internal <= rom_data_in;  -- captura ROM[rs]
                    state          <= FETCH_B;

                -- FETCH_B: envia rt para ROM; ULA opera com reg_a_internal e ROM[rt]
                when FETCH_B =>
                    state <= STORE_RAM;

                -- STORE_RAM: habilita escrita na RAM no endereco rd
                when STORE_RAM =>
                    state <= FINISHED;

                -- FINISHED: sinaliza done; aguarda start='0' para voltar ao repouso
                when FINISHED =>
                    if start = '0' then
                        state <= IDLE;
                    end if;

            end case;
        end if;
    end process;

    -- Processo combinacional: saidas de controle em funcao do estado atual
    process(state, rs, rt, rd, reg_a_internal)
    begin
        -- valores default (evita latch)
        rom_addr     <= (others => '0');
        ram_addr     <= (others => '0');
        ram_we       <= '0';
        reg_a_to_ula <= reg_a_internal;
        done         <= '0';

        case state is

            when IDLE =>
                null;

            when FETCH_A =>
                rom_addr <= rs;   -- aponta ROM para o operando A

            when FETCH_B =>
                rom_addr     <= rt;             -- aponta ROM para o operando B
                reg_a_to_ula <= reg_a_internal; -- disponibiliza A para a ULA

            when STORE_RAM =>
                ram_addr     <= rd;             -- endereco de escrita na RAM
                ram_we       <= '1';            -- habilita escrita
                reg_a_to_ula <= reg_a_internal;

            when FINISHED =>
                done <= '1';

        end case;
    end process;

end architecture;
