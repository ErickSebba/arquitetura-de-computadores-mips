-- Testbench para processador_top (VHDL-2008)
-- Cada operacao confere o valor gravado na RAM e a flag de overflow contra o valor esperado.
-- Uma divergencia gera erro (severity error) e o resumo final falha (severity failure).
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top is
end entity;

architecture sim of tb_top is

    component processador_top is
        port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            start       : in  std_logic;
            instruction : in  std_logic_vector(31 downto 0);
            done        : out std_logic
        );
    end component;

    signal clk         : std_logic := '0';
    signal reset       : std_logic := '1';
    signal start       : std_logic := '0';
    signal instruction : std_logic_vector(31 downto 0) := (others => '0');
    signal done        : std_logic;

    constant CLK_PERIOD : time := 10 ns;

    -- Copia do que foi gravado na RAM, capturada na escrita (porta di/we/addr do DUT)
    type ram_copia_t is array(0 to 31) of std_logic_vector(31 downto 0);
    signal ram_copia : ram_copia_t := (others => (others => 'U'));
    signal ovfl_na_escrita : std_logic := 'U';

    function make_rtype(rs, rt, rd, funct : integer)
        return std_logic_vector is
        variable instr : std_logic_vector(31 downto 0);
    begin
        instr(31 downto 26) := "000000";
        instr(25 downto 21) := std_logic_vector(to_unsigned(rs,    5));
        instr(20 downto 16) := std_logic_vector(to_unsigned(rt,    5));
        instr(15 downto 11) := std_logic_vector(to_unsigned(rd,    5));
        instr(10 downto  6) := "00000";
        instr( 5 downto  0) := std_logic_vector(to_unsigned(funct, 6));
        return instr;
    end function;

    type rom_t is array(0 to 31) of integer;
    constant ROM_VAL : rom_t := (
        0=>5,   1=>6,   2=>123, 3=>79,  4=>50,  5=>30,
        6=>100, 7=>25,  8=>60,  9=>85, 10=>40, 11=>15,
       12=>119,13=>65, 14=>90, 15=>10, 16=>150,17=>45,
       18=>105,19=>20, 20=>70, 21=>200,22=>55, 23=>130,
       24=>27, 25=>89, 26=>110,27=>35, 28=>145,29=>12,
       30=>180,31=>120
    );

begin

    DUT : processador_top
        port map (clk=>clk, reset=>reset, start=>start,
                  instruction=>instruction, done=>done);

    clk <= not clk after CLK_PERIOD / 2;

    -- Monitor: registra cada escrita na RAM do DUT
    monitor : process(clk)
        alias we_x   is << signal .tb_top.DUT.ram_we_s   : std_logic >>;
        alias addr_x is << signal .tb_top.DUT.ram_addr_s : std_logic_vector(4 downto 0) >>;
        alias di_x   is << signal .tb_top.DUT.ram_di_s   : std_logic_vector(31 downto 0) >>;
        alias ovfl_x is << signal .tb_top.DUT.ula_ovfl_s : std_logic >>;
    begin
        if rising_edge(clk) and we_x = '1' then
            ram_copia(to_integer(unsigned(addr_x))) <= di_x;
            ovfl_na_escrita <= ovfl_x;
        end if;
    end process;

    estimulos : process
        variable erros : natural := 0;
        procedure run_op(rs_i, rt_i, rd_i, funct_i : integer; op_str : string) is
            variable expected : integer;
        begin
            if funct_i = 32 or funct_i = 33 then
                expected := ROM_VAL(rs_i) + ROM_VAL(rt_i);
            else
                expected := ROM_VAL(rs_i) - ROM_VAL(rt_i);
            end if;
            instruction <= make_rtype(rs_i, rt_i, rd_i, funct_i);
            start <= '1';
            wait until done = '1';
            wait for CLK_PERIOD;
            if ram_copia(rd_i) = std_logic_vector(to_signed(expected, 32))
               and ovfl_na_escrita = '0' then
                report "[OK]    " & op_str &
                       ": ROM[" & integer'image(rs_i) & "]=" & integer'image(ROM_VAL(rs_i)) &
                       " op ROM[" & integer'image(rt_i) & "]=" & integer'image(ROM_VAL(rt_i)) &
                       " = " & integer'image(expected) &
                       " em RAM[" & integer'image(rd_i) & "]"
                severity note;
            else
                erros := erros + 1;
                report "[FALHA] " & op_str &
                       ": esperado " & integer'image(expected) &
                       " em RAM[" & integer'image(rd_i) & "], gravado " &
                       to_hstring(ram_copia(rd_i)) & ", overflow = " &
                       std_logic'image(ovfl_na_escrita)
                severity error;
            end if;
            start <= '0';
            wait for 50 ns;
        end procedure;

    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 10 ns;

        run_op(0,  1,  2, 32, "ADD     ");  -- 5  + 6   = 11
        run_op(3,  4,  5, 34, "SUB     ");  -- 79 - 50  = 29
        run_op(6,  7,  8, 33, "ADDU    ");  -- 100+ 25  = 125
        run_op(9, 10, 11, 35, "SUBU    ");  -- 85 - 40  = 45
        run_op(5,  2, 12, 34, "SUB_NEG ");  -- 30 - 123 = -93

        assert erros = 0
            report "=== " & integer'image(erros) & " operacao(oes) com resultado errado ==="
            severity failure;
        report "=== SIMULACAO CONCLUIDA: todas as operacoes conferem ===" severity note;
        wait;
    end process;

end architecture;
