library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
library work;
use work.all;

entity dwarf_top is port(
   clk        : in    std_logic;
   pport_data : inout std_logic_vector(7 downto 0);
   nWrite     : in    std_logic;
   nDataStr   : in    std_logic;
   nAddrStr   : in    std_logic;
   nWait      : out   std_logic;
   btns       : in    std_logic;
   Led        : out   std_logic_vector(7 downto 0);
   AB         : in    std_logic_vector(1 downto 0);
   sw         : in    std_logic_vector(7 downto 0);
   pwmout     : out    std_logic;
   btnu         : in    std_logic
   );
end dwarf_top;


architecture rtl of dwarf_top is
signal address : integer range 0 to 255;
type reg_type is array(0 to 255) of std_logic_vector(7 downto 0);
signal rreg : reg_type;
signal wreg : reg_type;
signal nDataStr_fall : std_logic;
signal nAddrStr_fall : std_logic;
signal din : std_logic_vector(7 downto 0);
signal enc : std_logic_vector(7 downto 0);
signal reset : std_logic;

component pwm is
Generic(
   width: natural := 8; -- Breite
   fclk : integer := 100000000; -- Taktfrequenz
   fpwm : integer := 20000 -- PWM-Frequenz;
);
Port(
   clk      : in  std_logic;
   pwmvalue : in  std_logic_vector (width-1 downto 0);
   pwmout   : out std_logic
);
end component;

begin

edge1:entity edge_detect port map(nDataStr,clk,open,nDataStr_fall);
edge2:entity edge_detect port map(nAddrStr,clk,open,nAddrStr_fall);

quad1:entity quad port map(clk,reset,open,enc,AB);

pwm1:component pwm port map(clk,wreg(0),pwmout);

process begin
wait until rising_edge(clk);
reset <= '0';
   if nDataStr = '0' and nDataStr_fall = '1' then
      if nWrite = '0' then
         wreg(address) <= pport_data;--EPP Data Write
      else
         --pport_data <= rreg(address);--EPP Data Read
         if address = 0 then
            reset <= '1';
            pport_data <= enc;
         end if;
      end if;
      
      address <= address + 1;
   else
      reset <= '0';
   end if;
   
   if nAddrStr = '0' and nAddrStr_fall = '1' then
      if nWrite = '0' then
         address <= to_integer(unsigned(pport_data));--EPP Address Write
      else
         pport_data <= std_logic_vector(to_unsigned(address,8));--EPP Address Read
      end if;
   end if;
   
   if nAddrStr = '1' and nDataStr = '1' then
      nWait <= '0';
      pport_data <= "ZZZZZZZZ";
   else
      nWait <= '1';
   end if;
   
   --led <= wreg(to_integer(unsigned(sw)));
   --led(0) <= A;
   --led(1) <= B;
   --led(7 downto 2) <= "000000";
   led <= enc;
   din(0) <= btns;
   din(7 downto 1) <= "1010101";
   rreg(16) <= din;
   --pwm <= btnu;
end process;


end rtl;
