library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

entity VGA is
generic(
		Hz:integer:=4;
		Hz2:integer:=2000000;
		r:integer:=14--0001100100
		);
port(
	clk:in std_logic;
	sw1:in std_logic;
	sw2:in std_logic;
	rst:in std_logic;
	hs_out:out std_logic;
	vs_out:out std_logic;
	LED:out std_logic_vector(7 downto 0);
	red:out std_logic_vector(2 downto 0);
	green:out std_logic_vector(2 downto 0);
	blue:out std_logic_vector(2 downto 0)
	);
end VGA;

architecture arch of VGA is
	signal clk25M:std_logic;
	signal hs:integer range 0 to 799;
	signal vs:integer range 0 to 524;
	signal move_state:std_logic_vector(3 downto 0);
	signal count2:std_logic;
	signal x0:integer range 0 to 799;--463  0111001111
	signal y0:integer range 0 to 524;--270 0100001110
	signal state_reg:std_logic_vector(0 to 2);
	signal state_sw1:std_logic:='0';
	signal state_sw2:std_logic:='0';
	signal VGA_R:std_logic:='0';
	signal VGA_G:std_logic:='0';
	signal VGA_B:std_logic:='0';
begin
	process(clk)
        variable count1 : integer range 1 to Hz:=1;
    begin
        if rising_edge(clk) then  
              
            if count1 = Hz then 
                count1 := 1;
            else
				count1 := count1 + 1;
            end if;
            
            if((count1 = Hz/2) or (count1 = Hz)) then  
                clk25M<= not clk25M;
            end if; 
        end if;
    end process;
	
	process(clk)
        variable count3 : integer range 1 to Hz2:=1;
    begin
        if rising_edge(clk) then  
              
            if count3 = Hz2 then 
                count3 := 1;
            else
				count3 := count3 + 1;
            end if;
            
            if((count3 = Hz2/2) or (count3 = Hz2)) then  
                count2<= not count2;
            end if; 
        end if;
    end process;

	RGB:process (clk25M)
	begin
		if rising_edge(clk25M)then
			if((hs>=x0)and(vs>=y0))then
				if(((hs-x0)*(hs-x0))+((vs-y0)*(vs-y0))<=r*r)then 
					if(VGA_G='1')then
						red <= "000" ;
						blue <= "000";
						green <= "001" ;
					else
						red <= "001" ;
						blue <= "001";
						green <= "001" ;
					end if;
				else                     ----------blank signal display
					red <= "000" ;
					blue <= "000";
					green <= "000" ;
				end if;
			elsif((hs<x0)and(vs>=y0))then
				if(((x0-hs)*(x0-hs))+((vs-y0)*(vs-y0))<=r*r)then 
					if(VGA_G='1')then
						red <= "000" ;
						blue <= "000";
						green <= "001" ;
					else
						red <= "001" ;
						blue <= "001";
						green <= "001" ;
					end if;
				else                     ----------blank signal display
					red <= "000" ;
					blue <= "000";
					green <= "000" ;
				end if;
			elsif((hs>=x0)and(vs<y0))then
				if(((hs-x0)*(hs-x0))+((y0-vs)*(y0-vs))<=r*r)then 
					if(VGA_G='1')then
						red <= "000" ;
						blue <= "000";
						green <= "001" ;
					else
						red <= "001" ;
						blue <= "001";
						green <= "001" ;
					end if;
				else                     ----------blank signal display
					red <= "000" ;
					blue <= "000";
					green <= "000" ;
				end if;
			elsif((hs<x0)and(vs<y0))then
				if(((x0-hs)*(x0-hs))+((y0-vs)*(y0-vs))<=r*r)then 
					if(VGA_G='1')then
						red <= "000" ;
						blue <= "000";
						green <= "001" ;
					else
						red <= "001" ;
						blue <= "001";
						green <= "001" ;
					end if;
				else                     ----------blank signal display
					red <= "000" ;
					blue <= "000";
					green <= "000" ;
				end if;
			else                     ----------blank signal display
				red <= "000" ;
				blue <= "000";
				green <= "000" ;
			end if;
			
			if((hs<295)and(hs>288)and(vs>240)and(vs<300))then
				if(VGA_B='1')then
					red <= "000" ;
					blue <= "001";
					green <= "000" ;
				else
					red <= "001" ;
					blue <= "001";
					green <= "001" ;
				end if;
			end if;
			if((hs>748)and(hs<755)and(vs>292)and(vs<352))then
				if(VGA_R='1')then
					red <= "001" ;
					blue <= "000";
					green <= "000" ;
				else
					red <= "001" ;
					blue <= "001";
					green <= "001" ;
				end if;
			end if;
            if((hs>396)and(hs<404)and(vs>296)and(vs<304))then
				if(VGA_R='1')then
					red <= "001" ;
					blue <= "000";
					green <= "000" ;
				else
					red <= "001" ;
					blue <= "001";
					green <= "001" ;
				end if;
			end if;
            
            if (hs > 0 )and(hs < 97 )then -- 96+1
				hs_out <= '0';
			else
				hs_out <= '1';
			end if;

			if (vs > 0 )and(vs < 3 )then -- 2+1   
				vs_out <= '0';
			else
				vs_out <= '1';
			end if;
			hs <= hs + 1 ;
			if (hs >= 799) then     ----incremental of horizontal line
				vs <= vs + 1;       ----incremental of vertical line
				hs <= 0;
			end if;
			
			if(vs >= 524)then
				vs <= 0;
			end if;
            
--			
		end if;
	end process;
	
	move:process(count2)
		variable t:integer range 0 to 150:=0;
	begin
		if(rst = '1')then
			move_state <= "1000";
			LED <= "11110000";
			x0 <= 303;
			y0 <= 270;
		elsif rising_edge(count2)then
			case move_state is
				when "0000"=>
				    LED <= "00000001";
					VGA_G<='0';
					if(y0<512)then
						x0<=x0+1;
						y0<=y0+1;
						t:=t+1;
						if(t>10)then
							if(sw1='1')then
								t:=0;
								move_state<="0101";
							elsif(sw2='1')then
								t:=0;
								move_state<="0100";
							end if;
						end if;
					else
						move_state<="0001";
					end if;
				when "0001"=>
				    LED <= "00000010";
					if(x0<736)then
						VGA_G<='0';
						t:=0;
						x0<=x0+1;
						y0<=y0-1;
						if(sw1='1')then
							t:=0;
							move_state<="0101";
						elsif(sw2='1')then
							t:=0;
							move_state<="0100";
						end if;
					else
						VGA_G<='1';
						t:=t+1;
						if(t<100)and(sw2='1')then
							t:=0;
							move_state<="1001";
						elsif(t>=100 and sw2='0')or(t=0 and sw2='1')then
							t:=0;
							move_state<="0100";	
						end if;
					end if;
				when "0010"=>
				    LED <= "00000100";
					VGA_G<='0';
					if(y0<512)then
						x0<=x0-1;
						y0<=y0+1;
						t:=t+1;
						if(t>10)then
							if(sw1='1')then
								t:=0;
								move_state<="0101";
							elsif(sw2='1')then
								t:=0;
								move_state<="0100";
							end if;
						end if;
					else
						move_state<="0011";
					end if;
				when "0011"=>
				    LED <= "00001000";
					if(x0>303)then
						VGA_G<='0';
						t:=0;
						x0<=x0-1;
						y0<=y0-1;
						if(sw1='1')then
							t:=0;
							move_state<="0101";
						elsif(sw2='1')then
							t:=0;
							move_state<="0100";
						end if;
					else
						VGA_G<='1';
						t:=t+1;
						if(t<100)and(sw1='1')then
							t:=0;
							move_state<="1000";
						elsif((t>=100)and(sw1='0'))or(t=0 and sw1='1')then
							t:=0;
							move_state<="0101";
						end if;
					end if;
				when "0100"=>
				    LED <= "00010000";
					move_state<="0110";
				when "0101"=>
				    LED <= "00100000";
					move_state<="0111";
				when "0110"=>
				    LED <= "01000000";
					t:=t+1;
					x0<=303;
					y0<=270;
					if(t>10)then
						t:=0;
						move_state<="1000";
					end if;
				when "0111"=>
				    LED <= "10000000";
					t:=t+1;
					x0<=736;
					y0<=321;
					if(t>10)then
						t:=0;
						move_state<="1001";
					end if;
				when "1000"=>
				    LED <= "00110011";
					VGA_G<='0';
					x0<=x0;
					y0<=y0;
					if(sw1='1')then
						move_state<="0000";
					end if;
				when "1001"=>
					VGA_G<='0';
					x0<=x0;
					y0<=y0;
					if(sw2='1')then
						move_state<="0010";
					end if;
				when others=>move_state<="0000";
			end case;
		end if;
	end process;

	color:process(sw1,sw2,move_state)
	begin
		if rising_edge(clk)then
			if(sw1='1')then
				VGA_B<='1';
			else
				VGA_B<='0';
			end if;
			if(sw2='1')then
				VGA_R<='1';
			else
				VGA_R<='0';
			end if;
		end if;
	end process;

end arch;