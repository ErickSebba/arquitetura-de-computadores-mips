library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ULA: suporta ADD (funct=100000=32), SUB (funct=100010=34),
--       ADDU (funct=100001=33), SUBU (funct=100011=35)
entity ula is
    port (
        a      : in  std_logic_vector(31 downto 0);
        b      : in  std_logic_vector(31 downto 0);
        funct  : in  std_logic_vector(5 downto 0);
        result : out std_logic_vector(31 downto 0);
        ovfl   : out std_logic
    );
end ula;

architecture rtl of ula is
begin
    -- res_signed e res_unsigned sao variaveis: como signals, o valor lido no mesmo
    -- processo era o da operacao anterior (atualizacao so no proximo delta).
    process(a, b, funct)
        variable sa  : signed(32 downto 0);
        variable sb  : signed(32 downto 0);
        variable ua  : unsigned(32 downto 0);
        variable ub  : unsigned(32 downto 0);
        variable res_signed   : signed(32 downto 0);   -- 33 bits para detectar overflow
        variable res_unsigned : unsigned(32 downto 0);
    begin
        -- extensao de sinal para deteccao de overflow
        sa := resize(signed(a), 33);
        sb := resize(signed(b), 33);
        ua := resize(unsigned(a), 33);
        ub := resize(unsigned(b), 33);

        result <= (others => '0');
        ovfl   <= '0';

        case funct is
            -- ADD: soma com sinal, detecta overflow
            when "100000" =>
                res_signed := sa + sb;
                result     <= std_logic_vector(res_signed(31 downto 0));
                -- overflow ocorre quando bit 32 difere do bit 31
                if res_signed(32) /= res_signed(31) then
                    ovfl <= '1';
                else
                    ovfl <= '0';
                end if;

            -- ADDU: soma sem sinal (sem trap de overflow)
            when "100001" =>
                res_unsigned := ua + ub;
                result       <= std_logic_vector(res_unsigned(31 downto 0));
                ovfl         <= res_unsigned(32);  -- carry out

            -- SUB: subtracao com sinal, detecta overflow
            when "100010" =>
                res_signed := sa - sb;
                result     <= std_logic_vector(res_signed(31 downto 0));
                if res_signed(32) /= res_signed(31) then
                    ovfl <= '1';
                else
                    ovfl <= '0';
                end if;

            -- SUBU: subtracao sem sinal
            when "100011" =>
                res_unsigned := ua - ub;
                result       <= std_logic_vector(res_unsigned(31 downto 0));
                ovfl         <= '0';

            when others =>
                result <= (others => '0');
                ovfl   <= '0';
        end case;
    end process;
end architecture;
