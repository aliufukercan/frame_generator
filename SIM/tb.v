`timescale 1ns / 1ps

/*
Author: Ali Ufuk Ercan
Description: Testbench for the design, tests every pattern.
Version: 1.00
*/

module tb();

parameter FPS               = 30;
parameter CLK_FREQ_HZ       = 100000000;
parameter FVAL2LVAL         = 50;
parameter LVAL2DVAL         = 80;

parameter WIDTH             = 640;
parameter HEIGHT            = 480;
parameter LVAL_HIGH         = 800;
parameter LVAL_LOW          = 100;
    
parameter BPP               = 8;
    
reg clk = 0;
reg rst = 0;
reg en = 0;
reg [2:0] sel = 0;

wire fval;
wire lval;
wire dval;
wire [7:0] pix_data;

always #5 clk=~clk;

frame_gen #(
    .FPS(FPS),
    .CLK_FREQ_HZ(CLK_FREQ_HZ),
    .FVAL2LVAL(FVAL2LVAL),
    .LVAL2DVAL(LVAL2DVAL),
    .DVAL_HIGH(WIDTH),
    .ROW_COUNT(HEIGHT),
    .LVAL_HIGH(LVAL_HIGH),
    .LVAL_LOW(LVAL_LOW),
    .BPP(BPP))
FRAME_GEN(
    
    .clk(clk),
    .rst(rst),
    .en(en),
    .sel(sel),
    .fval(fval),
    .lval(lval),
    .dval(dval),
    .pix_data(pix_data)

);
   
initial begin
@(posedge clk);
rst <= 1;
@(posedge clk);
rst <= 0;
en <= 1;
sel <= 3'b000;

@(posedge fval);
@(posedge fval);
sel <= 3'b001;

@(posedge fval);
sel <= 3'b010;

@(posedge fval);
sel <= 3'b011;

@(posedge fval);
sel <= 3'b111;
end

initial begin
#150_000_000;  
$finish;
end

endmodule
