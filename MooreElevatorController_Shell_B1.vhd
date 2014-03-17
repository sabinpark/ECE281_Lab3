----------------------------------------------------------------------------------
-- Company: USAFA
-- Engineer: Sabin Park
-- 
-- Create Date:    23:06:06 03/11/2014 
-- Design Name: 	 Lab3
-- Module Name:    MooreElevatorController_Shell_B1 - Behavioral 
-- Description:	 B functionality, part 1: More Floors
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MooreElevatorController_Shell_B1 is
    Port ( clk : in  STD_LOGIC;
			  led_clk : in std_logic;  -- added for A, Part 1 functionality
           reset : in  STD_LOGIC;
           stop : in  STD_LOGIC;
           up_down : in  STD_LOGIC ;
           floor : out  STD_LOGIC_VECTOR(3 downto 0);
			  floor_tens : out STD_LOGIC_VECTOR(3 downto 0);
			  LED_output : out std_logic_vector(7 downto 0));  -- added for A, Part 1 functionality
end MooreElevatorController_Shell_B1;

architecture Behavioral of MooreElevatorController_Shell_B1 is
type floor_state_type is (floor2, floor3, floor5, floor7, floor11, floor13, floor17, floor19);

signal floor_state : floor_state_type;

signal shift_reg : STD_LOGIC_VECTOR(7 downto 0) := X"00";  -- added for A, Part 1 functionality

begin

--This line will set up a process that is sensitive to the clock
floor_state_machine: process(clk, up_down, stop, reset, led_clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			floor_state <= floor2;
		elsif stop = '0' then
			case floor_state is
				-- 1
				when floor2 =>
					if(up_down = '1') then
						floor_state <= floor3;
					else
						floor_state <= floor2;
					end if;
				-- 2
				when floor3 =>
					if(up_down = '1') then
						floor_state <= floor5;
					else
						floor_state <= floor2;
					end if;
				-- 3
				when floor5 =>
					if(up_down = '1') then
						floor_state <= floor7;
					else
						floor_state <= floor3;
					end if;
				-- 4
				when floor7 =>
					if(up_down = '1') then
						floor_state <= floor11;
					else
						floor_state <= floor5;
					end if;
				-- 5
				when floor11 =>
					if(up_down = '1') then
						floor_state <= floor13;
					else
						floor_state <= floor7;
					end if;
				-- 6
				when floor13 =>
					if(up_down = '1') then
						floor_state <= floor17;
					else
						floor_state <= floor11;
					end if;
				-- 7
				when floor17 =>
					if(up_down = '1') then
						floor_state <= floor19;
					else
						floor_state <= floor13;
					end if;
				-- 8
				when floor19 =>
					if(up_down = '1') then
						floor_state <= floor19;
					else
						floor_state <= floor17;
					end if;
			end case;
		elsif stop = '1' then
			case floor_state is
				when floor2 =>
					floor_state <= floor2;
				when floor3 =>
					floor_state <= floor3;
				when floor5 =>
					floor_state <= floor5;
				when floor7 =>
					floor_state <= floor7;	
				when floor11 =>
					floor_state <= floor11;
				when floor13 =>
					floor_state <= floor13;
				when floor17 =>
					floor_state <= floor17;
				when floor19 =>
					floor_state <= floor19;	
			end case;
		end if;
	end if;
						
end process;

-- A Part 1 Functionality
-- process that is sensitive to the led clock
light_show: process(led_clk)
begin
	-- on the rising edge of the clk...
	if rising_edge(led_clk) then
		-- if we're moving up, then blink from left to right
		if up_down = '1' and stop = '0' and floor_state /= floor19 then 
            shift_reg(6 downto 0) <= shift_reg(7 downto 1);
            shift_reg(7) <= '1';
				if shift_reg(0) = '1' then
					shift_reg <= "00000000";
				end if;
		-- if we're moving down, then blink from right to left
		elsif up_down = '0' and stop = '0' and floor_state /= floor2 then
				shift_reg(7 downto 1) <= shift_reg(6 downto 0);
				shift_reg(0) <= '1';
				if shift_reg(7) = '1' then
					shift_reg <= "00000000";
				end if;
		-- otherwise, just display full led's
		else
				shift_reg <= "11111111";
		end if;
	end if;
end process;


-- Define the output logic
floor <= "0010" when (floor_state = floor2) else
			"0011" when (floor_state = floor3) else
			"0101" when (floor_state = floor5) else
			"0111" when (floor_state = floor7) else
			"0001" when (floor_state = floor11) else
			"0011" when (floor_state = floor13) else
			"0111" when (floor_state = floor17) else
			"1001" when (floor_state = floor19) else
			"0001";
			
floor_tens <= "0001" when (floor_state = floor11 or floor_state = floor13 or floor_state = floor17 or floor_state = floor19) else
				  "0000";

LED_output <= shift_reg;  -- added for A, Part 1 functionality


end Behavioral;

