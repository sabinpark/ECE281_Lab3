ECE281_Lab3
===========

Sabin's Lab 3

# *Functionality*
* **Required Functionality:** 
	- *BASIC MOORE* checked by Captain Silva
	- *BASIC MEALY* checked by Captain Silva
* **B Functionality:** 
	- *MORE FLOORS* checked by Captain Silva
	- *CHANGE INPUTS* checked by Dr. Neebel
* **A Functionality:** 
	- *MOVING LIGHTS* checked by Dr. Neebel and Captain Silva
	- *MULTIPLE ELEVATORS* checked by Dr. Neebel and Captain Silva


# Prelab
I was provided five files:
  1. Clock_Divider.vhd
  2. nexys2_sseg.vhd
  3. Nexys2_top_shell.vhd
  4. nibble_to_sseg.vhd
  5. pinout.ucf

Given these files and a very simple box of the Nexys2_top_shell, I read through the comments and came up with a schematic of my own.  

![alt text](https://raw.github.com/sabinpark/ECE281_Lab3/master/Nexys2_top_shell_schematic.PNG "Nexys2_top_shell Schematic")

As shown in the schematic, several signals such as the switch, btn, and reset have not been assigned to anything yet.

# Lab

## Code Critique

#### Bad Code
```vhdl
	--clk'event and clk='1' is VHDL-speak for a rising edge
	if clk'event and clk='1' then
		...
```
Although this code works, this coding practice is bad because programmers may confuse this syntax and later try to do things like this (which will not synthesize properly):
```vhdl
	if clk'event and clk='1' and up_down='1' then
		...
```
#### Good Code
```vhdl
	if rising_edge(clk) then
		...
```
This code is good because it does the same thing as the bad code above, but it is easier to read and makes it less likely for errors in the future.

#### Bad Code
```vhdl
	floor_state_machine: process(clk)
		...
```
This code is bad because it creates memory.  Later on, the code will change *floor_state* depending on what the values of *up_down*, *stop*, and *reset* are.  If the sensitivity does not contain these signals as well, then although the code is still functional, we are committing bad coding practice by allowing vhdl to infer memory.
#### Good Code
```vhdl
	floor_state_machine: process(clk, up_down, stop, reset)
```
This code fixes the problem above by putting *up_down*, *stop*, and *reset* in the sensitivity list.  Thus, memory is not accidentally created, but the program still works as it should.


## Part 1: Required Functionality

### Moore
First, I added the moore component declaration under all of the other premade components in the Nexys2_top_shell file. This section was pretty standard.

```vhdl
	COMPONENT MooreElevatorController_Shell
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		stop : IN std_logic;
		up_down : IN std_logic;          
		floor : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
```

I then added the component instantiation of the Moore elevator controller to the Nexys2_top_shell.  I also had to create a signal called *moore_floor* that was set to *nibble0*.  This signal will be used to display the current floor of the elevator on the SSEG.

```vhdl
	Inst_MooreElevatorController_Shell: MooreElevatorController_Shell PORT MAP(
		clk => ClockBus_sig(25),
		reset => btn(3),
		stop => switch(0),
		up_down => switch(1),
		floor => moore_floor
	);
```

Now that I had the components and the instantiations in the nexys2 top shell file, I was able to update the schematic.  Below is the new top shell schematic:

![alt text](https://raw.github.com/sabinpark/ECE281_Lab3/master/Nexys2_top_shell_schematic_part_B.PNG "Nexys2_top_shell Schematic with Part B")

The zoomed in schematic of the moore and mealy portion is below:

![alt text](https://raw.github.com/sabinpark/ECE281_Lab3/master/Moore_Mealy_Zoomed_Schematic.PNG "Moore/Mealy Zoomed Schematic")

### Test (Moore)
I started at floor 1 and allowed the elevator to rise up floor by floor until it reached floor 4.  In the middle, I tested the stop functionality by setting *stop* to 1.  When *stop* equaled 1, the elevator stayed on the floor without moving up.  At floor 4, the elvator remained where it was.  Once I set *up_down* to 0, the elevator moved down floor by floor.  At floor 3, I tested out the stop functionality again, and the SSEG did display the current floor without going further down.  At floor 2, I set *stop* to 1, then reset the elevator.  The elevator then returned to 1 as it should.  Functionality = success!

### Mealy
Very similar to the Moore section, I simply declared the mealy component right underneath the moore component.  The mealy instantiation was also declared right underneath the moore instantiation. The only differences were that I had to create two more signals instead of 1, and I also had to set another nibble to read the 2nd SSEG (for the next floor).  The signals I created were *mealy_floor* and *mealy_next_floor*.  

Below is the mealy instantiation:
```vhdl
	Inst_MealyElevatorController_Shell: MealyElevatorController_Shell PORT MAP(
		clk => ClockBus_sig(25),
		reset => btn(3),
		stop => switch(0),
		up_down => switch(1),
		floor => mealy_floor,
		nextfloor => mealy_next_floor
	);
```

#### *UPDATE*
I did run into a problem in that the console returned an error.  The problem lied with the fact that I had an if-statement that checked for both the rising edge *AND* a std_logic value within my mealy shell vhdl.  This was not good coding practice.
``` vhdl
	if stop = '0' and rising_edge(clk) then
	-- ... rest of code
```
To fix my error, I got rid of *stop* from the if-statement and instead moved it down one level in the if-statement hierarchy.  This was allowed because now the program did not check for both a std_logic signal and a clock input.  As a result, the code was now functional and worked properly.

### Test (Mealy)
Similar to the Moore test, I went through floor by floor and check the stop functionality.  For this test, I also made sure my *nextfloor* value was correct as well.  If *up_down* was 1, then I expected my *nextfloor* to be one floor above (unless I was on floor 4, which then would display *nextfloor* as 4).  If *up_down* was 0, then I expected my *nextfloor* to be one floor below (unless I was on floor 1, which would display *nextfloor* as 1).  The stop functionality was tested as well and worked as designed.  Mealy test = success!


## Part 2: B Functionality

I changed the Nexys2_top_shell so that each functionality part will be tested at once.  For example, for the required functionality, I set nibble0 for the moore functionality and nibbles 2 and 3 for the mealy functionality.  For the B functionality, I set nibbles 0 and 1 for the more floors functionality and nibble3 for the change inputs functionality.  This made it easier to comment out and test out the functionalities with minimal time loss.  Do not let the multiple sseg outputs confuse you!  Basically, the left side of the sseg displays one functionality and the right side displays another functionality. 

*NOTE*: the lab guidance suggested that I use the MOORE elevator controller as the baseline for the additional functionality.  

### More Floors
This functionality will allow the elevator controller to handle the first 8 prime numbered floors.  The floors are as follows (from high to low):

* Floor 19
* Floor 17
* Floor 13
* Floor 11
* Floor 7
* Floor 5
* Floor 3
* Floor 2

This part simply tests whether I can properly set my outputs and display them into any arbitrary value (in this case, prime numbers).

That being said, I created a new module called *MooreElevatorController_Shell_B1*, which was very similar to the original moore elevator controller shell.  The only differences were that I added more cases for four more floors, and I also had to define four more output logic statements and states.  Another key addition was a new std_logic_vector called *floor_tens*, which was used to set the tens place digit value.  Specifically, I set *floor_tens* to a value of 0 for floors 2, 3, 5, and 7, while I set the value to 1 for floors 11, 13, 17, and 19.  I had to do it this way in order to properly display the floor number on the sseg.  Essentially, I set nibble0 for the ones place value and nibble1 to the tens place value.

Below is the changed output logic that accounts for both digits:
```vhdl
	floor <= "0010" when (floor_state = floor2) else
		 "0011" when (floor_state = floor3) else
		 "0101" when (floor_state = floor5) else
		 "0111" when (floor_state = floor7) else
		 "0001" when (floor_state = floor11) else
		 "0011" when (floor_state = floor13) else
		 "0111" when (floor_state = floor17) else
		 "1001" when (floor_state = floor19) else
		 "0001";
				
	floor_tens <= "0001" when (floor_state = floor11 or floor_state = floor13 
		      or floor_state = floor17 or floor_state = floor19) else
		      "0000";
```

With four more floors, with half of them being two digits, I synthesized, implemented, generated the programming file, then finally configured the fpga.  *stop*, *reset*, and *up_down* still were programmed to the same buttons and switches from earlier.  I conducted the same test (now with four additional floors) and found that everything worked as it was supposed to.  The sseg did display the correct floors as expected.  SUCCESS!

### Change Inputs
This functionality will have the input as a 3-bit number specifying the floor to go to, instead of having *stop* and *up_down* as the inputs.  The floors will be numbered from 0 to 7, and the elevator will have to go floor by floor without skipping any floors in between.  Also, the floor will move once per clock edge.

*NOTE* I got rid of *reset* as well since the sseg will display a value corresponding to the switch configuration.

I began by creating a new module called *MooreElevatorController_Shell_B2*.  This module has two inputs, *clk* and *desired_floor*.  *clk* is the same as the previous modules.  *desired_floor* is a 3-bit std_logic_vector that will be set by using three switches.  This module has one output called *output_floor*, which will be used to send the floor number to display on the sseg.

Per the requirement, I set 8 states ranging from 0 to 7 within the signal, *floor_state*.

Since I cannot set the output signal inside of the process, *floor_state_machine*, I had to create an intermediary signal called *current_floor*, which was a std_logic_vector (2:0) used to temporarily take in the value of the current floor.

In the process, I first checked for a rising edge of the clock.  Inside of that if-statement, I checked whether the current floor was below the desired floor, above the desired floor, or at the desired floor.  If the current floor was not at the desired floor, the current floor would increment/decrement by one floor until the two floors matched.

*NOTE* I had to cast *current_floor* to *unsigned* before adding/subtracting by 1, then recasted the answer to a *std_logic_vector*.
```vhdl
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
		
		.
		.
		.
```

Right afterwards, I created another set of if-statements to set the value of *floor_state* according to the value of *current_floor*.  
```vhdl
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
```

Finally, for the output logic, I set the value of *output_floor* according to the value of *floor_state*.  *NOTE* I essentially had to add a 0 to the MSB of *current_floor* (3 bits) in order to properly set the nibble value in the main shell file.  Below is the code for the output logic. 

```vhdl
	-- output logic that sets the value of the output floor
	output_floor <= "0000" when (floor_state = floor0) else
			"0001" when (floor_state = floor1) else
			"0010" when (floor_state = floor2) else
			"0011" when (floor_state = floor3) else
			"0100" when (floor_state = floor4) else
			"0101" when (floor_state = floor5) else
			"0110" when (floor_state = floor6) else
			"0111";
```

Like with the previously added functionalities, I added the component and instantiation of this module to the Nexys2_top_shell file.  I set *nibble0* to a new signal I created called *moore_floor_b2*, the value of *output_floor*.

I ran the newly generated bit file on the fpga with the switches initially set to "000".  As expected, the sseg displayed a "0000".  When I flipped the switch corresponding to the LSB, the elevator moved up to "0001".  I flipped the switches to "111", and the sseg eventually made its way up to "0007".  I then went back down to a switch configuration of "000" to find that the elevator moved down to "0000".  The floors were changed by 1 floor at a time per the instructions.  And of course, the sseg continued to display the floor number of the corresponding switch configuration the whole time the program was running.  B functionality is now complete!

## Part 3: A Functionality

### Moving Lights
For this functionality, I decided to add more code to the Moore elevator controller.  Specifically, I chose the *MooreElevatorController_Shell_B1* file to work with (the prime number floors).  I created an input called *LED_clk* which was used because I wanted the moving lights to be a bit faster than the clk cycle of the actual change in floors.  I also created another output of a std_logic_vector type (7:0) called *LED_output*, which was used to determine which LEDs would turn on or off.  I made an intermediary signal called *shift_reg*, which was used to manipulate and store the values of the LED output before setting it equal in the output logic section.

*NOTE*  I set *LED_clk* to *ClockBus_sig(21)*, instead of *ClockBus_sig(25)*.  Again, this was so that the light show would happen at a faster rate--purely for aesthetic reasons.

I created another process called *light_show*, which was sensitive to the new clock signal, *LED_clk*.  On the rising edge of the clock, the process checked for the values of *up_down* and *stop*, and also checked whether the current floor was 2 (lowest floor) or 19 (highest floor).  The code made it so that the LEDs would turn on from the left to the right only if *up_down* was 1, *stop* was 0, and the current floor was not floor 19.  Likewise, the LEDs would turn on from right to left only if *up_down* was 0, *stop* was 0, and the current floor was not floor 2.  Otherwise, the LEDs would just all be turned on.

Here is the code for the process *light_show*:
```vhdl
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

```

At the end, I simply set *LED_output* to *shift_reg*.
```vhdl
	LED_output <= shift_reg;  -- added for A, Part 1 functionality
```

The corresponding component and instantiation within the Nexys2_top_shell file was updated and the program was tested on the fpga.  Everything worked as it was supposed to!


### Multiple Elevators
For this funcitonality, I created a whole new module called *MooreElevatorController_Shell_A2*.  This new module had many inputs and outputs as shown below:
```vhdl
Port ( clk : in  STD_LOGIC;
       desired_floor : in  STD_LOGIC_VECTOR (3 downto 0);  -- designated by the switches
       request_floor : in  STD_LOGIC_VECTOR (3 downto 0);  -- floor that requests elevator; use switches
       pickmeup : in  std_logic;
       E1_floor_output : out STD_LOGIC_VECTOR (3 downto 0);  -- sseg
       E2_floor_output : out STD_LOGIC_VECTOR (3 downto 0);  -- sseg
       current_floor_output : out STD_LOGIC_VECTOR (3 downto 0);  -- sseg
       desired_floor_output : out STD_LOGIC_VECTOR (3 downto 0)); -- sseg
```
*desired_floor* is the switch-designated floor the user wants to go to.  *request_floor* is the switch-designated floor the user starts from.  As shown in the updated nexys top shell, *desired_floor* is determined using switches 7 to 5, while *request_floor* is determined by switches 2 to 0. 

*pickmeup* is a signal used to tell the program that the user now wants to change floors.  Metaphorically, it is like the "close doors" button on an actual elevator.  *pickmeup* is determined by the press button 3.  

*E1_floor_output* and *E2_floor_output* are outputs that are used to show which floor each elevator is on using the SSEG.  I set E1 to SSEG 4 and E2 to SSEG 3.  *current_floor_output* and *desired_floor_output* are obviously the current and desired floors which are displayed on SSEG SSEG 1 and SSEG 0, respectively.  See the image below for help.

![alt text](https://raw.github.com/sabinpark/ECE281_Lab3/master/Multiple_Elevators_Guide.PNG "Multiple Elevators Guide")

To work with all of the inputs and outputs, I created intermediary signals:
```vhdl
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
```
Since I have two elevators, I created a floor_state_type signal for each elevator.  I then created the current floor signals for both elevators and for the user's current floor.  

*NOTE* These signals were arbitrarily initialized to the values shown above so that the user can see noticeable changes right when the program starts without any need to manipulate the inputs.  

*elevator_number* is used to determine which elevator to move.  I made the executive decision to use elevator 1 when *elevator_number* = 1, and use elevator 2 when *elevator_number* = 0.  *transporting* is a boolean that is used to separate the two main stages of this functionality: 1) pick an elevator and go to the requested floor and 2) take the passengers from requested floor to the desired floor.  *start* is used to ensure that the two stages are properly separated.  If not separated, the program will continue to jump between floors and will not be guaranteed to be in a stable state.  I set *start* to true whenever the button is pressed (*pickmeup* = 1).  In this way, the program is essentially able to restart from new user inputs.

The actual process is clock sensitive to the rising edge.  First, the program will set the floor states of both elevators and the user's current floor with the corresponding std_logic values.  

For example:
```vhdl
if current_floor = "-000" then floor_state <= floor0;
	...
```

The program will then check if *pickmeup* is 1.  If so, *start* will be set to *true*, allowing the actual floor manipulation to begin.  *NOTE* I created both *pickmeup* and *start* in such a way because I wanted the program to re-read the user inputs right when the button is pressed (with the rising edge), and not constantly re-read the user inputs (the elevators would not properly move the floors if that happened).  

And so, if *start* is true, then the program sets *current_floor* to *request_floor*, which will be important for manipulating the value of *current_floor*.  From here, if *transporting* is false (meaning the user does not have an elevator on their floor), then the program begins to compare the distance of the elevators to the current floor of the user.  
```vhdl
	-- if E1 is closer to the requested floor...
	if abs(signed(request_floor) - signed(E1_current_floor)) < 
		abs(signed(request_floor) - signed(E2_current_floor)) then
		...
```
*NOTE* I had to use *signed* instead of *unsigned* because subtraction would not have worked without it.  

From here, the program chooses the elevator to use (set *elevator_number* to the desired elevator to move), then changes the elevator one floor at a time until the elevator's floor matches the user's floor.
```vhdl
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
```
If both elevators are of equal distance from the user's floor, the program will simply choose elevator 1.

At this point, at least one of the elevators is on the user's floor.  The elevator will now move up to the desired floor in almost exactly the same manner it did to reach the originally requested floor.  The user's floor is incremented/decremented exxactly the same as the moving elevator.  This shows that the user is inside (moving with) the elevator.  The elevator and the user will then stop once each signal equals the desired floor.  *start* and *transporting* are both reset to *false*, allowing the user to change the inputs as desired.  

As for the output logic, everything is essentially the same except there are now more signals.

# Documentation

### Moving Lights
For A part 1 functionality (moving lights), I looked through the code [here](http://startingelectronics.com/software/VHDL-CPLD-course/tut11-shift-register/) to get started.  This site gave me the idea to set the last 7 led lights to the value of the first 7 led lights to create the moving light effect.  


