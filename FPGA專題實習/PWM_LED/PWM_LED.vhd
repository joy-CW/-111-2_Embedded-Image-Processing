library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity PWM_LED is
    generic(Hz:integer:=1000000);
	port(
		clk : in std_logic;
		rst : in std_logic;
		LED : out std_logic
		);
end PWM_LED;

architecture Behavioral of PWM_LED is
	signal cnt1_max : std_logic_vector(7 downto 0);
	signal cnt2_max : std_logic_vector(7 downto 0);
	signal clk_100Hz : std_logic;
	signal cnt1 : std_logic_vector(7 downto 0);
	signal cnt2 : std_logic_vector(7 downto 0);
	type STATE_TYPE is (S0, S1);
	signal state_max : STATE_TYPE;
	signal state_FSM : STATE_TYPE;
begin
    DIV:process(clk)
        variable count1:integer range 1 to Hz:=1;
	begin
		if rising_edge(clk)then
			if(count1=Hz)then
				count1:=1;
			else
				count1:=count1+1;
			end if;
			if((count1=Hz/2)or(count1=Hz))then
				clk_100Hz <= not clk_100Hz;
			end if;
		end if;
    end process;
    
	LED_FSM:process(clk,rst,state_FSM)
	begin
		if rst = '1' then
			state_FSM <= S0;
		elsif rising_edge(clk)then
			case state_FSM is
				when S0 =>  --亮
					if cnt1 >= cnt1_max then
						state_FSM <= S1;
					else
						state_FSM <= S0;
					end if;
				when S1 =>  --暗
					if cnt2 >= cnt2_max then
						state_FSM <= S0;
					else
						state_FSM <= S1;
					end if;
				when others => null;
			end case;
		end if;
	end process;
	
	cnt_max_FSM:process(clk,rst,state_max)
	begin
		if rst = '1' then
			state_max <= S0;
		elsif rising_edge(clk_100Hz)then
			case state_max is
				when S0 =>  --持續變亮
				    if cnt1_max < "11111111" then
						cnt1_max <= cnt1_max + '1';
						cnt2_max <= cnt2_max - '1';
					else
						state_max <= S1;
					end if;
				when S1 =>  --持續變暗
				    if cnt2_max < "11111111" then
						cnt1_max <= cnt1_max - '1';
						cnt2_max <= cnt2_max + '1';
					else
						state_max <= S0;
					end if;
				when others => null;
			end case;
		end if;
	end process;
	
	PWM:process(clk,rst,state_FSM,cnt1_max,cnt2_max)
	begin
		if rst = '1' then
			cnt1 <= "00000000";
			cnt2 <= "00000000";
		elsif rising_edge(clk)then
			case state_FSM is
				when S0 =>  --亮
					if cnt1 < cnt1_max then
						cnt1 <= cnt1 + '1';
						LED <= '1';
					else
						cnt1 <= cnt1_max - '1';
					end if;
				when S1 =>  --暗
					if cnt2 < cnt2_max then
						cnt2 <= cnt2 + '1';
						LED <= '0';
					else
						cnt2 <= cnt2_max - '1';
					end if;
				when others => null;
			end case;
		end if;
	end process;
	
end Behavioral;



			