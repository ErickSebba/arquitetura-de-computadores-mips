-- Testbench da ULA isolada (VHDL-2008): casos de borda e de overflow que a ROM do
-- processador nao alcanca (os operandos da ROM sao pequenos e positivos).
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ula is
end entity;

architecture sim of tb_ula is
    signal a, b, result : std_logic_vector(31 downto 0) := (others => '0');
    signal funct        : std_logic_vector(5 downto 0)  := (others => '0');
    signal ovfl         : std_logic;

    constant F_ADD  : std_logic_vector(5 downto 0) := "100000";
    constant F_ADDU : std_logic_vector(5 downto 0) := "100001";
    constant F_SUB  : std_logic_vector(5 downto 0) := "100010";
    constant F_SUBU : std_logic_vector(5 downto 0) := "100011";
begin
    DUT : entity work.ula
        port map (a => a, b => b, funct => funct, result => result, ovfl => ovfl);

    process
        variable erros : natural := 0;

        procedure caso(nome : string; f : std_logic_vector(5 downto 0);
                       va, vb, esperado : std_logic_vector(31 downto 0);
                       ovfl_esperado : std_logic) is
        begin
            a <= va; b <= vb; funct <= f;
            wait for 10 ns;
            if result = esperado and ovfl = ovfl_esperado then
                report "[OK]    " & nome severity note;
            else
                erros := erros + 1;
                report "[FALHA] " & nome & ": esperado " & to_hstring(esperado) &
                       " ovfl=" & std_logic'image(ovfl_esperado) & ", obtido " &
                       to_hstring(result) & " ovfl=" & std_logic'image(ovfl)
                severity error;
            end if;
        end procedure;
    begin
        --   nome                          funct   a            b            esperado     ovfl
        caso("ADD  5 + 6",                 F_ADD,  x"00000005", x"00000006", x"0000000B", '0');
        caso("ADD  -1 + 1",                F_ADD,  x"FFFFFFFF", x"00000001", x"00000000", '0');
        caso("ADD  overflow positivo",     F_ADD,  x"7FFFFFFF", x"00000001", x"80000000", '1');
        caso("ADD  overflow negativo",     F_ADD,  x"80000000", x"FFFFFFFF", x"7FFFFFFF", '1');
        caso("SUB  79 - 50",               F_SUB,  x"0000004F", x"00000032", x"0000001D", '0');
        caso("SUB  30 - 123 (negativo)",   F_SUB,  x"0000001E", x"0000007B", x"FFFFFFA3", '0');
        caso("SUB  overflow negativo",     F_SUB,  x"80000000", x"00000001", x"7FFFFFFF", '1');
        caso("SUB  overflow positivo",     F_SUB,  x"7FFFFFFF", x"FFFFFFFF", x"80000000", '1');
        caso("ADDU carry",                 F_ADDU, x"FFFFFFFF", x"00000001", x"00000000", '1');
        caso("ADDU sem carry",             F_ADDU, x"00000064", x"00000019", x"0000007D", '0');
        caso("SUBU 3 - 5 (sem trap)",      F_SUBU, x"00000003", x"00000005", x"FFFFFFFE", '0');
        caso("funct invalido",             "000000", x"00000003", x"00000005", x"00000000", '0');

        assert erros = 0
            report "=== " & integer'image(erros) & " caso(s) da ULA com resultado errado ==="
            severity failure;
        report "=== ULA: todos os casos conferem ===" severity note;
        wait;
    end process;
end architecture;
