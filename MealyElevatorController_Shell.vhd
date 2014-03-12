----------------------------------------------------------------------------------
-- Company: USAFA/DFEC
-- Engineer: Silva
-- 
-- Create Date:    10:33:47 07/07/2012 
-- Design Name: 
-- Module Name:    MooreElevatorController_Silva - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
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

entity MealyElevatorController_Shell is
    Port ( clk 		: in  STD_LOGIC;
           reset 		: in  STD_LOGIC;
           stop 		: in  STD_LOGIC;
           up_down 	: in  STD_LOGIC;
           floor 		: out STD_LOGIC_VECTOR (3 downto 0);
			  nextfloor : out std_logic_vector (3 downto 0));
end MealyElevatorController_Shell;

architecture Behavioral of MealyElevatorController_Shell is

type floor_state_type is (floor1, floor2, floor3, floor4);

signal floor_state : floor_state_type;

begin

---------------------------------------------------------
--Code your Mealy machine next-state process below
--Question: Will it be different from your Moore Machine?
--Answer: Yes
---------------------------------------------------------
floor_state_machine: process(up_down, stop, clk)
begin
--Insert your state machine below:
	-- this is gonna be asynchronous
	if rising_edge(clk) then
		if reset = '1' then
			floor_state <= floor1;
		elsif stop = '0' then
			case floor_state is
				when floor1 =>
					if(up_down = '1') then
						floor_state <= floor2;
					else
						floor_state <= floor1;
					end if;
				when floor2 =>
					if(up_down = '1') then
						floor_state <= floor3;
					else
						floor_state <= floor1;
					end if;
				when floor3 =>
					if(up_down = '1') then
						floor_state <= floor4;
					else
						floor_state <= floor2;
					end if;
				when floor4 =>
					if(up_down = '1') then
						floor_state <= floor4;
					else
						floor_state <= floor3;
					end if;
			end case;
		elsif stop = '1' then
			case floor_state is
				when floor1 =>
					floor_state <= floor1;
				when floor2 =>
					floor_state <= floor2;
				when floor3 =>
					floor_state <= floor3;
				when floor4 =>
					floor_state <= floor4;	
			end case;
		end if;
	end if;
						
end process;	

-----------------------------------------------------------
--Code your Ouput Logic for your Mealy machine below
--Remember, now you have 2 outputs (floor and nextfloor)
-----------------------------------------------------------
floor <= "0001" when (floor_state = floor1) else
			"0010" when (floor_state = floor2) else
			"0011" when (floor_state = floor3) else
			"0100" when (floor_state = floor4) else
			"0001";
nextfloor <= "0001" when (floor_state = floor1 and up_down = '0') else
				 "0001" when (floor_state = floor2 and up_down = '0') else
				 "0010" when (floor_state = floor1 and up_down = '1') else
				 "0010" when (floor_state = floor3 and up_down = '0') else
				 "0011" when (floor_state = floor2 and up_down = '1') else
				 "0011" when (floor_state = floor4 and up_down = '0') else
				 "0100" when (floor_state = floor3 and up_down = '1') else
				 "0100" when (floor_state = floor4 and up_down = '1') else
				 "0001";

end Behavioral;