----------------------------------------------------------------------------------
-- Company: USAFA
-- Engineer: Sabin Park
-- 
-- Create Date:    00:42:27 03/18/2014
-- Design Name: 	 Lab3
-- Module Name:    MooreElevatorController_Shell_A2 - Behavioral 
-- Description:	 A functionality, part 2: Multiple Elevators
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity MooreElevatorController_Shell_A2 is
    Port ( clk 	 		 : in  STD_LOGIC;
           desired_floor : in  STD_LOGIC_VECTOR (3 downto 0);  -- designated by the switches
           request_floor : in  STD_LOGIC_VECTOR (3 downto 0);  -- floor that requests elevator; use switches
			  pickmeup		 : in  std_logic;
			  E1_floor_output	 	  : out STD_LOGIC_VECTOR (3 downto 0);  -- sseg
			  E2_floor_output		  : out STD_LOGIC_VECTOR (3 downto 0);  -- sseg
           current_floor_output : out STD_LOGIC_VECTOR (3 downto 0);  -- sseg
			  desired_floor_output : out STD_LOGIC_VECTOR (3 downto 0)); -- sseg
end MooreElevatorController_Shell_A2;

architecture Behavioral of MooreElevatorController_Shell_A2 is

	type floor_state_type is (floor0, floor1, floor2, floor3, floor4, floor5, floor6, floor7);
	signal floor_state : floor_state_type;
	signal E1_floor_state : floor_state_type;
	signal E2_floor_state : floor_state_type;
	
	signal current_floor : STD_LOGIC_VECTOR (3 downto 0) := request_floor;
	signal E1_current_floor : STD_LOGIC_VECTOR (3 downto 0) := "0111";
	signal E2_current_floor : STD_LOGIC_VECTOR (3 downto 0) := "0111";
	
	signal elevator_number : bit;  -- '1' is elevator 1, '0' is elevator 2
	signal transporting : boolean := false;
	signal start : boolean := false;
	
begin

floor_state_machine: process(clk, request_floor, desired_floor, pickmeup)
begin

	-- check on the rising edge of the clock
	if rising_edge(clk) then
	
		-- sets the floor state to the current floor
		if current_floor = "-000" then
			floor_state <= floor0;
		elsif current_floor = "-001" then
			floor_state <= floor1;
		elsif current_floor = "-010" then
			floor_state <= floor2;
		elsif current_floor = "-011" then
			floor_state <= floor3;
		elsif current_floor = "-100" then
			floor_state <= floor4;
		elsif current_floor = "-101" then
			floor_state <= floor5;
		elsif current_floor = "-110" then
			floor_state <= floor6;
		elsif current_floor = "-111" then
			floor_state <= floor7;
		end if;

		-- sets the elevator floor states to the respective elevator's current floor
		
		-- Elevator 1
		if E1_current_floor = "-000" then
			E1_floor_state <= floor0;
		elsif E1_current_floor = "-001" then
			E1_floor_state <= floor1;
		elsif E1_current_floor = "-010" then
			E1_floor_state <= floor2;
		elsif E1_current_floor = "-011" then
			E1_floor_state <= floor3;
		elsif E1_current_floor = "-100" then
			E1_floor_state <= floor4;
		elsif E1_current_floor = "-101" then
			E1_floor_state <= floor5;
		elsif E1_current_floor = "-110" then
			E1_floor_state <= floor6;
		elsif E1_current_floor = "-111" then
			E1_floor_state <= floor7;
		end if;
		
		-- Elevator 2
		if E2_current_floor = "-000" then
			E2_floor_state <= floor0;
		elsif E2_current_floor = "-001" then
			E2_floor_state <= floor1;
		elsif E2_current_floor = "-010" then
			E2_floor_state <= floor2;
		elsif E2_current_floor = "-011" then
			E2_floor_state <= floor3;
		elsif E2_current_floor = "-100" then
			E2_floor_state <= floor4;
		elsif E2_current_floor = "-101" then
			E2_floor_state <= floor5;
		elsif E2_current_floor = "-110" then
			E2_floor_state <= floor6;
		elsif E2_current_floor = "-111" then
			E2_floor_state <= floor7;
		end if;

	
	
		if pickmeup = '1' then
			start <= true;
		else
			-- do nothing
		end if;
	
		if start = true then
		
			current_floor <= request_floor;
	
			-- if the requester is not currently being transported by an elevator...
			if transporting = false then
		
				-- if E1 is closer to the requested floor...
				if abs(signed(request_floor) - signed(E1_current_floor)) < abs(signed(request_floor) - signed(E2_current_floor)) then
					-- then move E1 towards current floor
					
					elevator_number <= '1';
					
					-- if requested floor is below the elevator...
					if request_floor < E1_current_floor then
						E1_current_floor <= std_logic_vector(unsigned(E1_current_floor) - 1);
					-- if requested floor is above the elevator
					elsif request_floor > E1_current_floor then
						E1_current_floor <= std_logic_vector(unsigned(E1_current_floor) + 1);
					else
						E1_current_floor <= request_floor;
						transporting <= true;
					end if;
				-- if E2 is closer to the requested floor....
				elsif abs(signed(request_floor) - signed(E2_current_floor)) < abs(signed(request_floor) - signed(E1_current_floor)) then
					-- then move E2 towards current floor
					
					elevator_number <= '0';
					
					if request_floor < E2_current_floor then
						E2_current_floor <= std_logic_vector(unsigned(E2_current_floor) - 1);
					elsif request_floor > E2_current_floor then
						E2_current_floor <= std_logic_vector(unsigned(E2_current_floor) + 1);
					else
						E2_current_floor <= request_floor;
						transporting <= true;
					end if;
					
				else
					-- otherwise, move E1 because it does not matter which one we move

					elevator_number <= '1';

					if request_floor < E1_current_floor then
						E1_current_floor <= std_logic_vector(unsigned(E1_current_floor) - 1);
					elsif request_floor > E1_current_floor then
						E1_current_floor <= std_logic_vector(unsigned(E1_current_floor) + 1);
					else
						E1_current_floor <= request_floor;
						transporting <= true;
					end if;
					
				end if;
				
			-- at this point, one of the elevators has reached the requested floor
			-- now ready to go to the desired floor
			else

				if elevator_number = '1' then
					if current_floor < desired_floor then
						current_floor <= std_logic_vector(unsigned(current_floor) + 1);
						E1_current_floor <= std_logic_vector(unsigned(E1_current_floor) + 1);
					elsif current_floor > desired_floor then
						current_floor <= std_logic_vector(unsigned(current_floor) - 1);
						E1_current_floor <= std_logic_vector(unsigned(E1_current_floor) - 1);
					else
						current_floor <= desired_floor;
						E1_current_floor <= desired_floor;
						start <= false;
						transporting <= false;
					end if;
				else -- if elevator_number is a 0 (E2)
					if current_floor < desired_floor then
						current_floor <= std_logic_vector(unsigned(current_floor) + 1);
						E2_current_floor <= std_logic_vector(unsigned(E2_current_floor) + 1);
					elsif current_floor > desired_floor then
						current_floor <= std_logic_vector(unsigned(current_floor) - 1);
						E2_current_floor <= std_logic_vector(unsigned(E2_current_floor) - 1);
					else
						current_floor <= desired_floor;
						E2_current_floor <= desired_floor;
						start <= false;
						transporting <= false;
					end if;					
				end if;
			end if;
		else
			-- essentialy do nothing
		end if;
		
		
	end if;
end process;

-- output logic that sets the value of the output floor
current_floor_output <=  "0000" when (floor_state = floor0) else
								 "0001" when (floor_state = floor1) else
								 "0010" when (floor_state = floor2) else
								 "0011" when (floor_state = floor3) else
								 "0100" when (floor_state = floor4) else
								 "0101" when (floor_state = floor5) else
								 "0110" when (floor_state = floor6) else
								 "0111" when (floor_state = floor7); 
					 
desired_floor_output <=  "0000" when (desired_floor = "0000") else
								 "0001" when (desired_floor = "0001") else
								 "0010" when (desired_floor = "0010") else
								 "0011" when (desired_floor = "0011") else
								 "0100" when (desired_floor = "0100") else
								 "0101" when (desired_floor = "0101") else
								 "0110" when (desired_floor = "0110") else
								 "0111" when (desired_floor = "0111");
					 
E1_floor_output <= "0000" when (E2_floor_state = floor0) else
						 "0001" when (E1_floor_state = floor1) else
						 "0010" when (E1_floor_state = floor2) else
						 "0011" when (E1_floor_state = floor3) else
						 "0100" when (E1_floor_state = floor4) else
						 "0101" when (E1_floor_state = floor5) else
						 "0110" when (E1_floor_state = floor6) else
						 "0111" when (E1_floor_state = floor7);
					 
E2_floor_output <= "0000" when (E2_floor_state = floor0) else
						 "0001" when (E2_floor_state = floor1) else
						 "0010" when (E2_floor_state = floor2) else
						 "0011" when (E2_floor_state = floor3) else
						 "0100" when (E2_floor_state = floor4) else
						 "0101" when (E2_floor_state = floor5) else
						 "0110" when (E2_floor_state = floor6) else
						 "0111" when (E2_floor_state = floor7);

end Behavioral;

