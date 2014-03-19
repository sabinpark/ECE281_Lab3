----------------------------------------------------------------------------------
-- Company: USAFA
-- Engineer: Silva
-- 
-- Create Date:    12:43:25 07/07/2012 
-- Module Name:    Nexys2_Lab3top - Behavioral 
-- Target Devices: Nexys2 Project Board
-- Tool versions: 
-- Description: This file is a shell for implementing designs on a NEXYS 2 board
-- 
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

entity Nexys2_top_shell is
    Port ( 	clk_50m 	: in  STD_LOGIC;
				btn 		: in  STD_LOGIC_VECTOR (3 DOWNTO 0);
				switch 	: in  STD_LOGIC_VECTOR (7 DOWNTO 0);
				SSEG_AN 	: out STD_LOGIC_VECTOR (3 DOWNTO 0);
				SSEG 		: out STD_LOGIC_VECTOR (7 DOWNTO 0);
				LED 		: out STD_LOGIC_VECTOR (7 DOWNTO 0));
end Nexys2_top_shell;

architecture Behavioral of Nexys2_top_shell is

---------------------------------------------------------------------------------------
--This component converts a nibble to a value that can be viewed on a 7-segment display
--Similar in function to a 7448 BCD to 7-seg decoder
--Inputs: 4-bit vector called "nibble"
--Outputs: 8-bit vector "sseg" used for driving a single 7-segment display
---------------------------------------------------------------------------------------
	COMPONENT nibble_to_sseg
	PORT(
		nibble : IN std_logic_vector(3 downto 0);          
		sseg 	 : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

---------------------------------------------------------------------------------------------
--This component manages the logic for displaying values on the NEXYS 2 7-segment displays
--Inputs: system clock, synchronous reset, 4 8-bit vectors from 4 instances of nibble_to_sseg
--Outputs: 7-segment display select signal (4-bit) called "sel", 
--         8-bit signal called "sseg" containing 7-segment data routed off-chip
---------------------------------------------------------------------------------------------
	COMPONENT nexys2_sseg
	GENERIC ( CLOCK_IN_HZ : integer );
	PORT(
		clk 	: IN  std_logic;
		reset : IN  std_logic;
		sseg0 : IN  std_logic_vector(7 downto 0);
		sseg1 : IN  std_logic_vector(7 downto 0);
		sseg2 : IN  std_logic_vector(7 downto 0);
		sseg3 : IN  std_logic_vector(7 downto 0);          
		sel 	: OUT std_logic_vector(3 downto 0);
		sseg  : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

-------------------------------------------------------------------------------------
--This component divides the system clock into a bunch of slower clock speeds
--Input: system clock 
--Output: 27-bit clockbus. Reference module for the relative clock speeds of each bit
--			 assuming system clock is 50MHz
-------------------------------------------------------------------------------------
	COMPONENT Clock_Divider
	PORT(
		clk : IN std_logic;          
		clockbus : OUT std_logic_vector(26 downto 0)
		);
	END COMPONENT;

-------------------------------------------------------------------------------------
--Below are declarations for signals that wire-up this top-level module.
-------------------------------------------------------------------------------------

signal nibble0, nibble1, nibble2, nibble3 : std_logic_vector(3 downto 0);
signal sseg0_sig, sseg1_sig, sseg2_sig, sseg3_sig : std_logic_vector(7 downto 0);
signal ClockBus_sig : STD_LOGIC_VECTOR (26 downto 0);

signal LED_sig : std_logic_vector (7 downto 0);

--------------------------------------------------------------------------------------
--Insert your design's component declaration below	
--------------------------------------------------------------------------------------
	
	-- [BISAIN] Added the moore component
	COMPONENT MooreElevatorController_Shell
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		stop : IN std_logic;
		up_down : IN std_logic;          
		floor : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	-- [BISIAN END]
	
	-- [BISAIN]
	COMPONENT MealyElevatorController_Shell
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		stop : IN std_logic;
		up_down : IN std_logic;          
		floor : OUT std_logic_vector(3 downto 0);
		nextfloor : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	-- [BISAIN END]
	
	-- [BISAIN] Added B Functionality
	-- Used for the B part 1 functionality
	-- same as the Moore component above
	-- Also used for A part 1 functionality (moving lights)
	COMPONENT MooreElevatorController_Shell_B1
	PORT(
		clk : IN std_logic;
		led_clk : in std_logic;
		reset : IN std_logic;
		stop : IN std_logic;
		up_down : IN std_logic;          
		floor : OUT std_logic_vector(3 downto 0);
		floor_tens : OUT std_logic_vector(3 downto 0);
		led_output : out std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	-- Used for the B part 2 functionality
	COMPONENT MooreElevatorController_Shell_B2
	PORT(
		clk : IN std_logic;
		desired_floor : IN std_logic_vector(2 downto 0);          
		output_floor : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	-- [BISAIN END]
	
	-- [BISAIN]  Added A part 2 functionality: Multiple Elevators
	COMPONENT MooreElevatorController_Shell_A2
	PORT(
		clk : IN std_logic;
		desired_floor : IN std_logic_vector(3 downto 0);
		request_floor : IN std_logic_vector(3 downto 0);  
		pickmeup : in std_logic;
		E1_floor_output : OUT std_logic_vector(3 downto 0);
		E2_floor_output : OUT std_logic_vector(3 downto 0);
		current_floor_output : OUT std_logic_vector(3 downto 0);
		desired_floor_output : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;	
	-- [BISAIN END]

--------------------------------------------------------------------------------------
--Insert any required signal declarations below
--------------------------------------------------------------------------------------
	-- [BISAIN]
	signal moore_floor : std_logic_vector(3 downto 0);
	
	signal mealy_floor : std_logic_vector(3 downto 0);
	signal mealy_next_floor : std_logic_vector(3 downto 0);
	
	signal moore_floor_b1 : std_logic_vector(3 downto 0);
	signal moore_floor_tens_b1 : std_logic_vector(3 downto 0);
	
	signal moore_floor_b2 : std_logic_vector(3 downto 0);
	
	signal A_E1_floor_output : std_logic_vector(3 downto 0);
	signal A_E2_floor_output : std_logic_vector(3 downto 0);
	signal A_current_floor_output : std_logic_vector(3 downto 0);
	signal A_desired_floor_output : std_logic_vector(3 downto 0);
	-- [BISAIN END]

begin

----------------------------
--code below tests the LEDs:
----------------------------
--LED <= CLOCKBUS_SIG(26 DOWNTO 19);

-- [BISAIN]
-- A Functionality: Changes the LED light pattern
-- sets the LED output to the signal I created that makes the light show
	--LED <= LED_sig;
	
-- A part 2:  purely for aesthetic reasons
	LED(7) <= Clockbus_sig(26);
	LED(6) <= Clockbus_sig(26);
	LED(5) <= Clockbus_sig(26);
	LED(4) <= Clockbus_sig(26);
	LED(3) <= Clockbus_sig(26);
	LED(2) <= Clockbus_sig(26);
	LED(1) <= Clockbus_sig(26);
	LED(0) <= Clockbus_sig(26);
-- [BISAIN END]

--------------------------------------------------------------------------------------------	
--This code instantiates the Clock Divider. Reference the Clock Divider Module for more info
--------------------------------------------------------------------------------------------
	Clock_Divider_Label: Clock_Divider PORT MAP(
		clk => clk_50m,
		clockbus => ClockBus_sig
	);

--------------------------------------------------------------------------------------	
--Code below drives the function of the 7-segment displays. 
--Function: To display a value on 7-segment display #0, set the signal "nibble0" to 
--				the value you wish to display
--				To display a value on 7-segment display #1, set the signal "nibble1" to 
--				the value you wish to display...and so on
--Note: You must set each "nibble" signal to a value. 
--		  Example: if you are not using 7-seg display #3 set nibble3 to "0000"
--------------------------------------------------------------------------------------

-- Required Functionality [MOORE and MEALY]
--nibble0 <= moore_floor;
--nibble1 <= "0000";
--nibble2 <= mealy_floor;
--nibble3 <= mealy_next_floor;

-- B Functionality [MORE FLOORS and CHANGE INPUTS]
-- A Functionality part 1 [MOVING LIGHTS only for MORE FLOORS]
--nibble0 <= moore_floor_b1;
--nibble1 <= moore_floor_tens_b1;
--nibble2 <= "0000";
--nibble3 <= moore_floor_b2;

-- A Functionality part 2 [MULTIPLE ELEVATORS]
nibble0 <= A_desired_floor_output;
nibble1 <= A_current_floor_output;
nibble2 <= A_E2_floor_output;
nibble3 <= A_E1_floor_output;

--This code converts a nibble to a value that can be displayed on 7-segment display #0
	sseg0: nibble_to_sseg PORT MAP(
		nibble => nibble0,
		sseg => sseg0_sig
	);

--This code converts a nibble to a value that can be displayed on 7-segment display #1
	sseg1: nibble_to_sseg PORT MAP(
		nibble => nibble1,
		sseg => sseg1_sig
	);

--This code converts a nibble to a value that can be displayed on 7-segment display #2
	sseg2: nibble_to_sseg PORT MAP(
		nibble => nibble2,
		sseg => sseg2_sig
	);

--This code converts a nibble to a value that can be displayed on 7-segment display #3
	sseg3: nibble_to_sseg PORT MAP(
		nibble => nibble3,
		sseg => sseg3_sig
	);
	
--This module is responsible for managing the 7-segment displays, you don't need to do anything here
	nexys2_sseg_label: nexys2_sseg 
	generic map ( CLOCK_IN_HZ => 50E6 )
	PORT MAP(
		clk => clk_50m,
		reset => '0',
		sseg0 => sseg0_sig,
		sseg1 => sseg1_sig,
		sseg2 => sseg2_sig,
		sseg3 => sseg3_sig,
		sel => SSEG_AN,
		sseg => SSEG
	);
	

-----------------------------------------------------------------------------
--Instantiate the design you wish to implement below and start wiring it up!:
-----------------------------------------------------------------------------

	-- [BISAIN]
	Inst_MooreElevatorController_Shell: MooreElevatorController_Shell PORT MAP(
		clk => ClockBus_sig(25),
		reset => btn(3),
		stop => switch(0),
		up_down => switch(1),
		floor => moore_floor	
	);
	-- [BISAIN END]
	
	-- [BISAIN]
	Inst_MealyElevatorController_Shell: MealyElevatorController_Shell PORT MAP(
		clk => ClockBus_sig(25),
		reset => btn(3),
		stop => switch(0),
		up_down => switch(1),
		floor => mealy_floor,
		nextfloor => mealy_next_floor
	);
	-- [BISAIN END]
	
	
	-- Used for B part 1 functionality
	-- same as the moore instantiation above
	-- Used also for A part 1 functionality
	Inst_MooreElevatorController_Shell_B1: MooreElevatorController_Shell_B1 PORT MAP(
		clk => ClockBus_sig(25),
		led_clk => ClockBus_sig(21),
		reset => btn(3),
		stop => switch(0),
		up_down => switch(1),
		floor => moore_floor_b1,
		floor_tens => moore_floor_tens_b1,
		LED_output => LED_sig
	);
	
	-- Used for B part 2 functionality
	Inst_MooreElevatorController_Shell_B2: MooreElevatorController_Shell_B2 PORT MAP(
		clk => ClockBus_sig(25),
		desired_floor(2) => switch(2),
		desired_floor(1) => switch(1),
		desired_floor(0) => switch(0),
		output_floor => moore_floor_b2
	);

	-- Used for A part 2 functionality
	Inst_MooreElevatorController_Shell_A2: MooreElevatorController_Shell_A2 PORT MAP(
		clk => ClockBus_sig(24),
		desired_floor(3) => '0',
		desired_floor(2) => switch(2),
		desired_floor(1) => switch(1),
		desired_floor(0) => switch(0),
		request_floor(3) => '0',
		request_floor(2) => switch(7),
		request_floor(1) => switch(6),
		request_floor(0) => switch(5),	
		pickmeup => btn(3), 
		E1_floor_output => A_E1_floor_output,
		E2_floor_output => A_E2_floor_output,
		current_floor_output => A_current_floor_output,
		desired_floor_output => A_desired_floor_output 
	);
	
end Behavioral;

