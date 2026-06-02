library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_32x32 is
    port (
        clk  : in  std_logic;
        we   : in  std_logic;
        addr : in  std_logic_vector(4 downto 0);
        di   : in  std_logic_vector(31 downto 0);
        do   : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of ram_32x32 is
    type ram_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal ram : ram_type := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                ram(to_integer(unsigned(addr))) <= di;
            end if;
        end if;
    end process;

    -- leitura assincrona
    do <= ram(to_integer(unsigned(addr)));
end architecture;
