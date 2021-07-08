`timescale 1ns / 1ps

/*
Author: Ali Ufuk Ercan
Description: Testbench for the design, tests every pattern.
Version: 1.00
*/

module tb();

parameter FPS               = 30;
parameter CLK_FREQ_HZ       = 100_000_000;
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

// For writing to file
integer full_black;
integer full_white;
integer gradient;
integer checkers;
integer logo;
reg [7:0] decoded_pix_data;

always #5 clk=~clk;

frame_gen #(
    .FPS(FPS),
    .CLK_FREQ_HZ(CLK_FREQ_HZ),
    .FVAL2LVAL(FVAL2LVAL),
    .LVAL2DVAL(LVAL2DVAL),
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT),
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

// Open the files
full_black = $fopen("D:/Vivado Projects/full_black.pgm","wb");
full_white = $fopen("D:/Vivado Projects/full_white.pgm","wb");
gradient = $fopen("D:/Vivado Projects/gradient.pgm","wb");
checkers = $fopen("D:/Vivado Projects/checkers.pgm","wb");
logo = $fopen("D:/Vivado Projects/logo.pgm","wb");

// Full-Black file headers
$fstrobe(full_black,"P5");
@(posedge clk);
$fwrite(full_black,WIDTH);
$fwrite(full_black," ");
$fstrobe(full_black,HEIGHT);
$fstrobe(full_black,"255");

// Full-White file headers
$fstrobe(full_white,"P5");
@(posedge clk);
$fwrite(full_white,WIDTH);
$fwrite(full_white," ");
$fstrobe(full_white,HEIGHT);
$fstrobe(full_white,"255");

// Gradient file headers
$fstrobe(gradient,"P5");
@(posedge clk);
$fwrite(gradient,WIDTH);
$fwrite(gradient," ");
$fstrobe(gradient,HEIGHT);
$fstrobe(gradient,"255");

// Checkers file headers
$fstrobe(checkers,"P5");
@(posedge clk);
$fwrite(checkers,WIDTH);
$fwrite(checkers," ");
$fstrobe(checkers,HEIGHT);
$fstrobe(checkers,"255");

// LOGO file headers
$fstrobe(logo,"P5");
@(posedge clk);
$fwrite(logo,WIDTH);
$fwrite(logo," ");
$fstrobe(logo,HEIGHT);
$fstrobe(logo,"255");


@(posedge clk);
rst <= 1;
@(posedge clk); 
rst <= 0;
en <= 1;

@(posedge fval); // Full Black
sel <= 3'b000;

@(posedge fval); // Full White
sel <= 3'b001;

@(posedge fval); // Gradient
sel <= 3'b010;

@(posedge fval); // Checkers
sel <= 3'b011;

@(posedge fval); // LOGO
sel <= 3'b111;

end

//Combinational Block for decoding
always @(pix_data) begin
    if (pix_data == 2'b00) 
        decoded_pix_data = 8'b00000000;
    else if (pix_data == 2'b11)
        decoded_pix_data = 8'b11111111;
    else 
        decoded_pix_data = 8'b01100100;    
end

// Write patterns to the files
always @(posedge clk) begin
    
    if (sel == 3'b000) begin
        if (dval)
            $fwriteb(full_black,"%c",pix_data);
    end else if (sel == 3'b001) begin
        if (dval)
            $fwriteb(full_white,"%c",pix_data);
    end else if (sel == 3'b010) begin
        if (dval)
            $fwriteb(gradient,"%c",pix_data);
    end else if (sel == 3'b011) begin
        if (dval)
            $fwriteb(checkers,"%c",pix_data);
    end else if (sel == 3'b111) begin
        if (dval)
            $fwriteb(logo,"%c",decoded_pix_data);
    end
end

initial begin
#150_000_000;
$fclose;  
$finish;
end

endmodule
