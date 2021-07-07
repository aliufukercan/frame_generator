
/*
Author: Ali Ufuk Ercan
Description: Frame generation top module.
Version: 1.01
*/

module frame_gen #(
    
    parameter FPS               = 30,
    parameter CLK_FREQ_HZ       = 100000000,
    parameter FVAL2LVAL         = 50,
    parameter LVAL2DVAL         = 80,

    parameter WIDTH             = 640,
    parameter HEIGHT            = 480,
    parameter LVAL_HIGH         = 800,
    parameter LVAL_LOW          = 100,
    
    parameter BPP               = 8
    
)(
        
    input clk,
    input rst,
    input en,               // for frame_timing_gen
    input [2:0] sel,        // for frame_pattern_gen
    
    output fval,
    output lval,
    output dval,
    output [BPP-1:0] pix_data
    
    );
 
// Wires
wire lval_negedge_out;
wire fval_posedge_out;
wire fval_out;
wire lval_out;
wire dval_out;
wire [7:0] pix_value; 

assign fval = fval_out;
assign lval = lval_out;
assign dval = dval_out;
assign pix_data = pix_value;


//Instantiations
frame_timing_gen #(.FPS(FPS),.CLK_FREQ_HZ(CLK_FREQ_HZ),.FVAL2LVAL(FVAL2LVAL),.LVAL2DVAL(LVAL2DVAL),
.DVAL_HIGH(WIDTH),.ROW_COUNT(HEIGHT),.LVAL_HIGH(LVAL_HIGH),.LVAL_LOW(LVAL_LOW)) 

FRAME_TIME_GEN (
    
    .clk(clk),
    .rst(rst),
    .en(en),
    .fval(fval_out),
    .lval(lval_out),
    .dval(dval_out),
    .lval_negedge_out(lval_negedge_out),
    .fval_posedge_out(fval_posedge_out)
    
);  

frame_pattern_gen #(.DVAL_HIGH(WIDTH),.ROW_COUNT(HEIGHT))
FRAME_PAT_GEN(
    
    .clk(clk),
    .rst(rst),
    .sel(sel),
    .dval(dval_out),
    .lval_negedge(lval_negedge_out),
    .fval_posedge(fval_posedge_out),
    .pix_value(pix_value)
    
);    

endmodule
