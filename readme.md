# Frame Generation Module

## Overview
- This module creates timing signals frame valid, line valid and data valid.
- Creates 6 different image patterns and outputs the corresponding pixel values in data valid signal.
- All signals are configured to be synchronous with the input clock.
- It is all written in Verilog.
</br></br>

## Source Files
---
Source File | Description | Input Ports | Output Ports
--- | --- | --- | ---
frame_gen.v | Top module. |clk, rst, en, sel|fval, lval, dval, pix_data
frame_timing_gen.v | Creates fval, lval and dval signals. | clk, rst, en | fval, lval, dval, lval_negedge_out, fval_posedge_out
frame_pattern_gen.v | Creates image patterns. | clk, rst, sel, dval, lval_negedge, fval_posedge | pix_value
pixel_memory_cubes.v </br> pixel_memory_logo.v </br>  pixel_memory_choco_bar.v| Reads and stores the pixel values in memory. | width, height | pix_value
decoder.v | Decodes the pixel values in memory.| pix_data, sel | decoded_pix_data
frame_grabber.v | Writes the decoded pixel values to a file. | clk, rst, fval, lval, dval, sel, en , pix_data |


</br>

## Parameters
---
Parameter Name | Description
--- | ---
FVAL2LVAL | Delay between fval and lval signal positive edges in clock cycles.
LVAL2DVAL | Delay between lval and dval signal positive edges in clock cycles.
WIDTH | Number of columns of the image frame.  
HEIGHT | Number of rows of the image frame.
LVAL_HIGH | LVAL signal high logic duration in clock cycles.
LVAL_LOW | LVAL signal low logic duration in clock cycles.
BPP | Number of bits per pixel.

</br>

## 1.1 frame_pattern_gen
Corresponding to the 3 bit selection input; full black, full white, gradient, checkers or company logo pattern's pixel values are outputted. Through the parameters, width and height values of the image frame are changeable.   
</br>

## 1.2 pixel_memory_cubes - pixel_memory_logo 
Because of the complexity of the code that will create the company logo and cubes patterns, it is preferred to create that patterns on tcl script language and using $readmemb command, store it in a block memory. It should be noted that in order to see the output data correctly, the file to be read should be placed in the simulation folder (xsim).
</br></br>

## 1.3 frame_grabber
This module is written to be used in the testbench, so it is unsynthesizable. By using state machines, it checks the timing signals and at the appropriate time, it writes the pixel values of the given frame to a memory. After the frame is done, it writes the pixel values in the memory to a file. 
</br></br>

## Simulation
---

## 1.1 tb
A testbench is present in the SIM folder that displays timing and all the parameter generation waveforms. 
