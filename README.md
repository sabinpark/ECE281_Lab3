ECE281_Lab3
===========

Sabin's Lab 3

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

### Test (Moore)
I started at floor 1 and allowed the elevator to rise up floor by floor until it reached floor 4.  In the middle, I tested the stop funcitonality by setting *stop* to 1.  When *stop* equaled 1, the elevator stayed on the floor without moving up.  At floor 4, the elvator remained where it was.  Once I set *up_down* to 0, the elevator moved down floor by floor.  At floor 3, I tested out the stop functionality again, and the SSEG did display the current floor without going further down.  At floor 2, I set *stop* to 1, then reset the elevator.  The elevator then returned to 1 as it should.  Functionality = success!

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

That being said, I first attempted to create this functionality by 

### Change Inputs
...
