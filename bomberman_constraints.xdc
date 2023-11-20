## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal
 set_property PACKAGE_PIN W5 [get_ports clk]							
 	set_property IOSTANDARD LVCMOS33 [get_ports clk]
 	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

##VGA Connector
set_property PACKAGE_PIN G19 [get_ports {VGA_RGB[8]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[8]}]
set_property PACKAGE_PIN H19 [get_ports {VGA_RGB[9]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[9]}]
set_property PACKAGE_PIN J19 [get_ports {VGA_RGB[10]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[10]}]
set_property PACKAGE_PIN N19 [get_ports {VGA_RGB[11]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[11]}]
set_property PACKAGE_PIN N18 [get_ports {VGA_RGB[0]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[0]}]
set_property PACKAGE_PIN L18 [get_ports {VGA_RGB[1]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[1]}]
set_property PACKAGE_PIN K18 [get_ports {VGA_RGB[2]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[2]}]
set_property PACKAGE_PIN J18 [get_ports {VGA_RGB[3]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[3]}]
set_property PACKAGE_PIN J17 [get_ports {VGA_RGB[4]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[4]}]
set_property PACKAGE_PIN H17 [get_ports {VGA_RGB[5]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[5]}]
set_property PACKAGE_PIN G17 [get_ports {VGA_RGB[6]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[6]}]
set_property PACKAGE_PIN D17 [get_ports {VGA_RGB[7]}]				
	set_property IOSTANDARD LVCMOS33 [get_ports {VGA_RGB[7]}]
set_property PACKAGE_PIN P19 [get_ports hsync]						
	set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property PACKAGE_PIN R19 [get_ports vsync]						
	set_property IOSTANDARD LVCMOS33 [get_ports vsync]

##USB HID (PS/2)
set_property PACKAGE_PIN C17 [get_ports PS2clk]						
	set_property IOSTANDARD LVCMOS33 [get_ports PS2clk]
	set_property PULLUP true [get_ports PS2clk]
set_property PACKAGE_PIN B17 [get_ports key_data]					
	set_property IOSTANDARD LVCMOS33 [get_ports key_data]	
	set_property PULLUP true [get_ports key_data]
	
# RESET SWITCH
set_property PACKAGE_PIN R2 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# BUTTONS
set_property PACKAGE_PIN U18 [get_ports PB_ENTER]
set_property IOSTANDARD LVCMOS33 [get_ports PB_ENTER]
set_property PACKAGE_PIN T18 [get_ports PB_UP]
set_property IOSTANDARD LVCMOS33 [get_ports PB_UP]
set_property PACKAGE_PIN W19 [get_ports PB_LEFT]
set_property IOSTANDARD LVCMOS33 [get_ports PB_LEFT]
set_property PACKAGE_PIN T17 [get_ports PB_RIGHT]
set_property IOSTANDARD LVCMOS33 [get_ports PB_RIGHT]
set_property PACKAGE_PIN U17 [get_ports PB_DOWN]
set_property IOSTANDARD LVCMOS33 [get_ports PB_DOWN]