library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_32x32 is
    port (
        addr : in  std_logic_vector(4 downto 0);
        data : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of rom_32x32 is
    type rom_type is array (0 to 31) of std_logic_vector(31 downto 0);
    constant ROM : rom_type := (
        0  => x"00000005",  -- posicao 0: valor 5
        1  => x"00000006",  -- posicao 1: valor 6
        2  => x"0000007B",  -- posicao 2: valor 123
        3  => x"0000004F",  -- posicao 3: valor 79
        4  => x"00000032",  -- posicao 4: valor 50
        5  => x"0000001E",  -- posicao 5: valor 30
        6  => x"00000064",  -- posicao 6: valor 100
        7  => x"00000019",  -- posicao 7: valor 25
        8  => x"0000003C",  -- posicao 8: valor 60
        9  => x"00000055",  -- posicao 9: valor 85
        10 => x"00000028",  -- posicao 10: valor 40
        11 => x"0000000F",  -- posicao 11: valor 15
        12 => x"00000077",  -- posicao 12: valor 119
        13 => x"00000041",  -- posicao 13: valor 65
        14 => x"0000005A",  -- posicao 14: valor 90
        15 => x"0000000A",  -- posicao 15: valor 10
        16 => x"00000096",  -- posicao 16: valor 150
        17 => x"0000002D",  -- posicao 17: valor 45
        18 => x"00000069",  -- posicao 18: valor 105
        19 => x"00000014",  -- posicao 19: valor 20
        20 => x"00000046",  -- posicao 20: valor 70
        21 => x"000000C8",  -- posicao 21: valor 200
        22 => x"00000037",  -- posicao 22: valor 55
        23 => x"00000082",  -- posicao 23: valor 130
        24 => x"0000001B",  -- posicao 24: valor 27
        25 => x"00000059",  -- posicao 25: valor 89
        26 => x"0000006E",  -- posicao 26: valor 110
        27 => x"00000023",  -- posicao 27: valor 35
        28 => x"00000091",  -- posicao 28: valor 145
        29 => x"0000000C",  -- posicao 29: valor 12
        30 => x"000000B4",  -- posicao 30: valor 180
        31 => x"00000078"   -- posicao 31: valor 120
    );
begin
    data <= ROM(to_integer(unsigned(addr)));
end architecture;
