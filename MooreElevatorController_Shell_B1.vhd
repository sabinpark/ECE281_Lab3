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
           reset : in  STD_LOGIC;
           stop : in  STD_LOGIC;
           up_down : in  STD_LOGIC;
           floor : out  STD_LOGIC_VECTOR(3 downto 0);
			  floor_tens : out STD_LOGIC_VECTOR(3 downto 0));
end MooreElevatorController_Shell_B1;

architecture Behavioral of MooreElevatorController_Shell_B1 is
type floor_state_type is (floor2, floor3, floor5, floor7, floor11, floor13, floor17, floor19);

signal floor_state : floor_state_type;

begin

--This line will set up a process that is sensitive to the clock
floor_state_machine: process(clk)
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

end Behavioral;

