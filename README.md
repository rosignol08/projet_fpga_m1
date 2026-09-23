# DCC Command Station on FPGA - Hardware/Software Co-design

This repository contains the final project developed for the "Programmable Systems" course (Master 1 SESI, Sorbonne University). 
The goal is to design and implement a **DCC (Digital Command Control) Command station** on an FPGA board to control model trains, utilizing a Hardware/Software (HW/SW) co-design approach. 

## Projet Objective

The DCC protocol allows for the individual control of locomotives and their accessories (speed, headlights, horn) by modulating the power supply voltage on the tracks. This project focuses on generating this strictly timed digital signal using an embedded processor combined with a custom hardware IP.

## System Architecture 

The system is deployed on a **Digilent Basys 3 (Artix 7)** development board and is divided into two main parts: 

### 1. Hardware (VHDL) 

Design of a dedicated IP (Intellectual Property), interfaced via the **AXI4-Lite** bus: 
- **Diviseur d'horloge & Timers:** To meet the strict timing constraints required by the DCC protocol (microsecond scale pulses);
- **Finit State Machine (FSM):** To sequence the transmission of logical bits in the DCC format.
- **Shift Register:** To store and serialize the complete DCC frame bit by bit.

### 2. Software (C)

Embedded application running on a **Microblaze** softcore processor:
- Polling user inputs (push buttons, slide switches on the board) via GPIO modules.
- Formatting DCC frames (train adress, speed instructions, lighting/sound functions, XOR error; detection byte).
- Dispatching the formatted frames to the hardware IP using custom C drivers.

## Prerequisites and Tools 
- Target Board: Digilent Basys 3 (Xilinx Artix-7)
- Synthesis & Implementation Tool: Xilinx Vivado (Recommended version: 2020.2)
- Software Development ENvironment: Xilinx Vitis
- Languages: VHDL, C

## Repository Structure 
- `/rtl/`: VHDL source files for the DCC Command Station IP (FSM, counters, registers).
- `/sw/`: C source code for the software application.
- `/docs/`: report of the project.
- `/constrains/`: Directory containing the packaged AXI IP for Vivado. 
- `/tb/`: testbench of the VHDL code.

## Usage
1. Hardware Generation: Open the project in Vivado, add the custom IP from the ip_repo, generate the Block Design, run synthesis/implementation, and generate the Bitstream.
2. Hardware Export: Export the hardware definition (.xsa file) for Vitis.
3. Software Compilation: Open Vitis, create a Platform Project using the exported .xsa file, and an Application Project with the provided C sources.
4. Execution: Program the FPGA with the Bitstream, then use the Run or Debug mode in Vitis to execute the C code on the Microblaze.
5. Testing: Connect the DCC output pin (PMOD B) to a Booster circuit connected to the tracks to control the model locomotives.

# Author 

**Ji Stéphane 
Chaffray Romaric**

Master 1 SESI Student - Sorbonne University
