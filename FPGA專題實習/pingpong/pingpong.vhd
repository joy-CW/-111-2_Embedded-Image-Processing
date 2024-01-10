library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity PWM_LED is
    generic(Hz:integer:=50000000;
			button_Hz:integer:=10000000);
	port(
		clk : in std_logic;
		rst : in std_logic;
		player1 : in std_logic;
		player2 : in std_logic;
		LED_out : out std_logic_vector(7 downto 0)
		);
end PWM_LED;

architecture Behavioral of PWM_LED is
	signal clk_2Hz : std_logic;
	signal clk_10Hz : std_logic;
	signal p1 : std_logic;
	signal p2 : std_logic;
	signal lose : std_logic;
	signal cnt : std_logic_vector(1 downto 0);
	signal rand : std_logic_vector(4 downto 0);
	signal rand_cnt : std_logic_vector(23 downto 0);
	signal rand_clk : std_logic;
	signal LED : std_logic_vector(7 downto 0);
	signal ball_state : std_logic_vector(3 downto 0);
	type STATE_TYPE is (S0, S1, S2, S3);
	signal state_max : STATE_TYPE;
	signal state_FSM : STATE_TYPE;
begin
    LED_out <= LED;
    DIV:process(clk)
        variable count1:integer range 1 to Hz:=1;
		variable count2:integer range 1 to button_Hz:=1;
	begin
		if rising_edge(clk)then
			if(count1=Hz)then
				count1:=1;
			else
				count1:=count1+1;
			end if;
			if((count1=Hz/2)or(count1=Hz))then
				clk_2Hz <= not clk_2Hz;
			end if;
			if(count2=button_Hz)then
				count2:=1;
			else
				count2:=count2+1;
			end if;
			if((count2=button_Hz/2)or(count2=button_Hz))then
				clk_10Hz <= not clk_10Hz;
			end if;
		end if;
    end process;
    
	ball_FSM:process(clk_2Hz,rst,state_FSM)
	begin
		if rst = '1' then
			state_FSM <= S0;
			lose <= '0';
		elsif rising_edge(clk_2Hz)then
			case state_FSM is
				when S0 =>  --球在左方，LED(7)亮
					if p1 = '1' then
						state_FSM <= S1;
						lose <= '0';
					else
						state_FSM <= S0;
					end if;
				when S1 =>  --球右移
					if p1 = '1' then     --player1搶拍
						state_FSM <= S2;
						lose <= '1';
					elsif p2 = '1' then
						if LED(0) = '1' then  --player2回擊成功
							state_FSM <= S3;
						else                  --player2搶拍
							state_FSM <= S0;
							lose <= '1';
						end if;
					elsif p2 = '0' then  --player2漏接
						if cnt >= "10" then
							state_FSM <= S0;
							lose <= '1';
						end if;
					else
						state_FSM <= S1;
					end if;
				when S2 =>  --球在右方，LED(0)亮
					if p2 = '1' then
						state_FSM <= S3;
						lose <= '0';
					else
						state_FSM <= S2;
					end if;
				when S3 =>  --球左移
					if p2 = '1' then     --player2搶拍
						state_FSM <= S0;
						lose <= '1';
					elsif p1 = '1' then
						if LED(7) = '1' then  --player1回擊成功
							state_FSM <= S1;
						else                  --player1搶拍
							state_FSM <= S2;
							lose <= '1';
						end if;
					elsif p1 = '0' then  --player1漏接
						if cnt >= "10" then
							state_FSM <= S2;
							lose <= '1';
						end if;
					else
						state_FSM <= S3;
					end if;
				when others => null;
			end case;
		end if;
	end process;
	
	ball_cnt:process(clk,rst,state_FSM)
	begin
		if rst = '1' then
			cnt <= "00";
		elsif rising_edge(clk_2Hz)then
			case state_FSM is
				when S1 =>  --球右移
					if LED(0) = '1' then
						if cnt < "10" then
							cnt <= cnt + '1';
						else
							cnt <= "00";
						end if;
					else
						cnt <= "00";
					end if;
				when S3 =>  --球左移
					if LED(7) = '1' then
						if cnt < "10" then
							cnt <= cnt + '1';
						else
							cnt <= "00";
						end if;
					else
						cnt <= "00";
					end if;
				when others => cnt <= "00";
			end case;
		end if;
	end process;
	
	ball:process(clk,rst,LED)
	begin
		if rising_edge(clk)then
			case ball_state is
				when "0000" => LED <= "10000000";
				when "0001" => LED <= "01000000";
				when "0010" => LED <= "00100000";
				when "0011" => LED <= "00010000";
				when "0100" => LED <= "00001000";
				when "0101" => LED <= "00000100";
				when "0110" => LED <= "00000010";
				when "0111" => LED <= "00000001";
				when "1000" => LED <= "11110000";
				when "1001" => LED <= "00001111";
				when others => null;
			end case;
		end if;
	end process;
	
	ball_move:process(rand_clk,rst,state_FSM)
	begin
		if rst = '1' then
			ball_state <= "0000";
		elsif rising_edge(rand_clk)then
			case state_FSM is
				when S0 =>  
					if lose = '1' then
						ball_state <= "1000";
					else
						ball_state <= "0000";
					end if;
				when S1 =>  --球右移
					if LED = "11110000" then
						ball_state <= "0000";
					elsif LED(0) = '0' then
						ball_state <= ball_state + '1';
					else
						ball_state <= "0111";
					end if;
				when S2 =>
					if lose = '1' then
						ball_state <= "1001";
					else
						ball_state <= "0111";
					end if;
				when S3 =>  --球左移
					if LED = "00001111" then
						ball_state <= "0111";
					elsif LED(7) = '0' then
						ball_state <= ball_state - '1';
					else
						ball_state <= "0000";
					end if;
				when others => null;
			end case;
		end if;
	end process;
	
	button:process(clk_10Hz,player1,player2)
	begin
		if rising_edge(clk_10Hz)then
			if player1 = '1' then
				p1 <= '1';
			else
				p1 <= '0';
			end if;
			if player2 = '1' then
				p2 <= '1';
			else
				p2 <= '0';
			end if;
		end if;
	end process;
	
	randon:process(clk,rst,rand)
	begin
		if rst = '1' then
			rand <= "10010";
		elsif rand_clk'event and rand_clk = '1' then
			rand(4) <= rand(3);
            rand(3) <= rand(2) xor rand(0);
            rand(2) <= rand(1) xor rand(0);
            rand(1) <= rand(0);
            rand(0) <= rand(4);
		end if;
	end process;
	
	randon_cnt:process(clk,rst,rand_cnt)
	begin
		if rst = '1' then
			rand_cnt <= "00000000"&"00000000"&"00000000";
			rand_clk <= '0';
		elsif rising_edge(clk)then
			if rand_cnt < rand&"000"&"00000000"&"00000000" then
				rand_cnt <= rand_cnt + '1';
			else
				rand_cnt <= "00000000"&"00000000"&"00000000";
				rand_clk <= not rand_clk;
			end if;
		end if;
	end process;
	
end Behavioral;