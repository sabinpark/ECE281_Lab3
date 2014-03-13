----------------------------------------------------------------------------------
-- Company: USAFA
-- Engineer: Sabin Park
-- 
-- Create Date:    23:31:45 03/12/2014 
-- Design Name: 	 Lab3
-- Module Name:    MooreElevatorController_Shell_B2 - Behavioral 
-- Description:	 B functionality, part 2: Change Inputs
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MooreElevatorController_Shell_B2 is
    Port ( clk : in  STD_LOGIC;
           desired_floor : in  STD_LOGIC_VECTOR (2 downto 0);
           output_floor : out  STD_LOGIC_VECTOR (3 downto 0));
end MooreElevatorController_Shell_B2;

architecture Behavioral of MooreElevatorController_Shell_B2 is

	type floor_state_type is (floor0, floor1, floor2, floor3, floor4, floor5, floor6, floor7);
	
	signal floor_state : floor_state_type;
	
	signal current_floor : STD_LOGIC_VECTOR (2 downto 0);

begin

floor_state_machine: process(clk)
begin
	-- check on the rising edge of the clock
	if rising_edge(clk) then
		-- if the current floor is below the desired floor, then go up one floor
		if current_floor < desired_floor then
			current_floor <= std_logic_vector(unsigned(current_floor) + 1);
		-- if the current floor is above the desired floor, then go down one floor
		elsif current_floor > desired_floor then
			current_floor <= std_logic_vector(unsigned(current_floor) - 1);
		-- otherwise, the current floor is at the desired floor
		else
			current_floor <= desired_floor;
		end if;
		
		-- sets the floor state to the current floor
		if current_floor = "000" then
			floor_state <= floor0;
		elsif current_floor = "001" then
			floor_state <= floor1;
		elsif current_floor = "010" then
			floor_state <= floor2;
		elsif current_floor = "011" then
			floor_state <= floor3;
		elsif current_floor = "100" then
			floor_state <= floor4;
		elsif current_floor = "101" then
			floor_state <= floor5;
		elsif current_floor = "110" then
			floor_state <= floor6;
		else
			floor_state <= floor7;
		end if;
		
	end if;		
end process;

-- output logic that sets the value of the output floor
output_floor <= "0000" when (floor_state = floor0) else
					 "0001" when (floor_state = floor1) else
					 "0010" when (floor_state = floor2) else
					 "0011" when (floor_state = floor3) else
					 "0100" when (floor_state = floor4) else
					 "0101" when (floor_state = floor5) else
					 "0110" when (floor_state = floor6) else
					 "0111";

end Behavioral;

