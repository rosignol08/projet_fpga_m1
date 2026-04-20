## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports CLK_100MHz]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK_100MHz]

## Switches
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs[0]}]; 
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs[1]}]; 
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs[2]}]; 
set_property -dict { PACKAGE_PIN W17 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs[3]}]; 

set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs[4]}]; 
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs[5]}]; 
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs[6]}]; 
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs[7]}]; 


set_property -dict { PACKAGE_PIN R2 IOSTANDARD LVCMOS33 } [get_ports {RESET}]; 


# Pmod JB 
set_property -dict { PACKAGE_PIN B16 IOSTANDARD LVCMOS33 } [get_ports SORTIE_DCC];


