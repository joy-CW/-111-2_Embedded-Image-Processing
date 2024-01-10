library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity pingpong is
generic(
		Hz : integer := 25000000
		);
port(
	clk : in std_logic;
	rst : in std_logic;
	button : in std_logic;
	IO : inout std_logic;
	led : out std_logic_vector(7 downto 0)
	);
end pingpong;

architecture arch of pingpong is
	signal clk_4Hz : std_logic;
	signal cnt : integer range 0 to 3;
	signal ball : integer range 0 to 8;
	type STATE_TYPE is (S0, S1, S2, S3);
	signal state : STATE_TYPE;
begin
	clk4:process(clk)
        variable count1 : integer range 1 to Hz:=1;
    begin
        if rising_edge(clk) then  
              
            if count1 = Hz then 
                count1 := 1;
            else
				count1 := count1 + 1;
            end if;
            
            if((count1 = Hz/2) or (count1 = Hz)) then  
                clk_4Hz<= not clk_4Hz;
            end if; 
        end if;
    end process;
	
	ball_state:process(clk,cnt)
	begin
		if rising_edge(clk)then
			case ball is
				when 0 => led <= "00000001";
				when 1 => led <= "00000010";
				when 2 => led <= "00000100";
				when 3 => led <= "00001000";
				when 4 => led <= "00010000";
				when 5 => led <= "00100000";
				when 6 => led <= "01000000";
				when 7 => led <= "10000000";
				when others => led <= "00000000";
			end case;
		end if;
	end process;
	
	FSM:process(clk,rst,state)
	begin
		if rst = '1' then
			state <= S0;
		elsif rising_edge(clk)then
			case state is
				when S0 => --初始狀態:等待發球
					if button = '1' then
						state <= S1;
					else
						state <= S0;
					end if;
				when S1 => --球向另一板子移動
					if IO = '1'then
						state <= S0;
					elsif ball = 7 then
						state <= S2;
					else
						state <= S1;
					end if;
				when S2 => --等待球回來
					if(IO = '1')then
						state <= S3;
					else
						state <= S2;
					end if;
				when S3 => --球往最外移動
					if IO = '1' then
						state <= S0;
					elsif ball = 0 then
						if cnt < 3 then
							if button = '1' then
								state <= S1;
							end if;
						else
							state <= S2;
						end if;
					else
						state <= S3;
					end if;
			end case;
		end if;
	end process;
	
	led_move:process(clk_4Hz,rst,ball,button,state)
	begin
		if rst = '1' then
			IO <= 'z';
			cnt <= 0;
		elsif rising_edge(clk_4Hz)then
			case state is
				when S0 => --初始狀態:等待發球
					IO <= 'z';
					ball <= 0;
				when S1 => --球向另一板子移動
					IO <= 'z';
					if ball = 7 or button = '1' then
						IO <= '1';
					else
						ball <= ball + 1;
					end if;
				when S2 => --等待球回來
					IO <= 'z';
					ball <= 8;
					if button = '1' then
						IO <= '1';
					end if;
				when S3 => --球往最外移動
					IO <= 'z';
					if ball = 0 then
						if cnt < 3 then
							cnt <= cnt + 1;
						else
							cnt <= 0;
						end if;
					else
						ball <= ball - 1;
					end if;
			end case;
		end if;
	end process;
	
end arch;