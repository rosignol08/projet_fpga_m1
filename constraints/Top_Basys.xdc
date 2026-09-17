## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports CLK_100MHz]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK_100MHz]

## Switches (MIS EN COMMENTAIRE CAR GERES PAR L'AUTOMATISATION BOARD DE VIVADO)
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs_tri_i[0]}]; 
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs_tri_i[1]}]; 
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs_tri_i[2]}]; 
set_property -dict { PACKAGE_PIN W17 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs_tri_i[3]}]; 
set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs_tri_i[4]}]; 
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs_tri_i[5]}]; 
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs_tri_i[6]}]; 
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports {Interrupteurs_tri_i[7]}];

## Reset
set_property -dict { PACKAGE_PIN R2 IOSTANDARD LVCMOS33 } [get_ports {RESET}]; 

## Pmod JB (La star du projet)
set_property -dict { PACKAGE_PIN B16 IOSTANDARD LVCMOS33 } [get_ports SORTIE_DCC];

