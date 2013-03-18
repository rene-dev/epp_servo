library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.all;

entity quad is
	port(
		clk			: in std_logic;															-- System Clock
		reset		: in std_logic;
		error		: out std_logic;
		quad		: out std_logic_vector(7 downto 0);										-- quad output
		ab			: in std_logic_vector(1 downto 0)											-- quad input
	);
end entity quad;

architecture behave_quad of quad is	
	signal cnt : integer := 0;
	signal state : std_logic_vector(1 downto 0);
	signal ab_in : std_logic_vector(1 downto 0);
	signal reset_rise : std_logic;
	
begin

edge1:entity edge_detect port map(reset,clk,reset_rise,open);

	process(clk) begin
		if rising_edge(clk) then
			ab_in <= ab;
		end if;
	end process;
  
	process(clk) begin
		if(rising_edge(clk)) then
			if(reset_rise = '1') then
				cnt <= 128;
				error <= '0';
				state <= ab_in;
			else
				case state is
					when "00" => 
						if(ab_in = "01") then 
							state <= "01"; cnt <= cnt + 1;
						elsif(ab_in = "10") then 
							state <= "10"; cnt <= cnt - 1;
						end if;
					when "01" => 
						if(ab_in = "11") then 
							state <= "11"; cnt <= cnt + 1;
						elsif(ab_in = "00") then 
							state <= "00"; cnt <= cnt - 1;
						end if;
					when "11" => 
						if(ab_in = "10") then 
							state <= "10"; cnt <= cnt + 1;
						elsif(ab_in = "01") then 
							state <= "01"; cnt <= cnt - 1;
						end if;
					when "10" => 
						if(ab_in = "00") then 
							state <= "00"; cnt <= cnt + 1;
						elsif(ab_in = "11") then 
							state <= "11"; cnt <= cnt - 1;
						end if;
					when others =>
				end case;
			end if;
		end if;
	end process;
	
	quad <= std_logic_vector(to_unsigned(cnt,8));
end behave_quad;
