library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Top Level: instancia e interliga todos os modulos
entity processador_top is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        start       : in  std_logic;
        instruction : in  std_logic_vector(31 downto 0);
        done        : out std_logic
    );
end entity;

architecture structural of processador_top is

    -- -------------------------------------------------------
    -- Declaracoes dos componentes
    -- -------------------------------------------------------
    component rom_32x32 is
        port (
            addr : in  std_logic_vector(4 downto 0);
            data : out std_logic_vector(31 downto 0)
        );
    end component;

    component ram_32x32 is
        port (
            clk  : in  std_logic;
            we   : in  std_logic;
            addr : in  std_logic_vector(4 downto 0);
            di   : in  std_logic_vector(31 downto 0);
            do   : out std_logic_vector(31 downto 0)
        );
    end component;

    component ula is
        port (
            a      : in  std_logic_vector(31 downto 0);
            b      : in  std_logic_vector(31 downto 0);
            funct  : in  std_logic_vector(5 downto 0);
            result : out std_logic_vector(31 downto 0);
            ovfl   : out std_logic
        );
    end component;

    component control_unit is
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
    end component;

    -- -------------------------------------------------------
    -- Sinais internos de interligacao
    -- -------------------------------------------------------

    -- ROM
    signal rom_addr_s : std_logic_vector(4 downto 0);
    signal rom_data_s : std_logic_vector(31 downto 0);

    -- RAM
    signal ram_addr_s : std_logic_vector(4 downto 0);
    signal ram_we_s   : std_logic;
    signal ram_di_s   : std_logic_vector(31 downto 0);  -- dado a escrever (resultado da ULA)
    signal ram_do_s   : std_logic_vector(31 downto 0);  -- dado lido (nao usado no fluxo principal)

    -- ULA
    signal ula_a_s      : std_logic_vector(31 downto 0);  -- operando A (vem da FSM)
    signal ula_b_s      : std_logic_vector(31 downto 0);  -- operando B (vem direto da ROM)
    signal ula_result_s : std_logic_vector(31 downto 0);
    signal ula_ovfl_s   : std_logic;

    -- Campo funct da instrucao (bits 5:0)
    alias funct_s : std_logic_vector(5 downto 0) is instruction(5 downto 0);

begin

    -- -------------------------------------------------------
    -- Instancias
    -- -------------------------------------------------------

    U_ROM : rom_32x32
        port map (
            addr => rom_addr_s,
            data => rom_data_s
        );

    U_RAM : ram_32x32
        port map (
            clk  => clk,
            we   => ram_we_s,
            addr => ram_addr_s,
            di   => ram_di_s,
            do   => ram_do_s
        );

    -- A ULA recebe:
    --   a     = reg_a_to_ula (operando A armazenado pela FSM)
    --   b     = saida da ROM (operando B atual)
    --   funct = campo funct da instrucao
    U_ULA : ula
        port map (
            a      => ula_a_s,
            b      => ula_b_s,
            funct  => funct_s,
            result => ula_result_s,
            ovfl   => ula_ovfl_s
        );

    U_FSM : control_unit
        port map (
            clk          => clk,
            reset        => reset,
            start        => start,
            instruction  => instruction,
            rom_data_in  => rom_data_s,
            rom_addr     => rom_addr_s,
            ram_addr     => ram_addr_s,
            ram_we       => ram_we_s,
            reg_a_to_ula => ula_a_s,
            done         => done
        );

    -- Operando B da ULA vem diretamente da saida da ROM
    ula_b_s <= rom_data_s;

    -- Dado a ser escrito na RAM e o resultado da ULA
    ram_di_s <= ula_result_s;

end architecture;
