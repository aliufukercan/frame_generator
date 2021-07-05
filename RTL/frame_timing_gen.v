
/*
Author: Ali Ufuk Ercan
Description: Timing generations for output pixel values.
Version: 1.00
*/

module frame_timing_gen #(

    parameter FPS               = 30,
    parameter CLK_FREQ_HZ       = 100000000,
    parameter FVAL2LVAL         = 50,
    parameter LVAL2DVAL         = 80,

    parameter DVAL_HIGH         = 640,
    parameter ROW_COUNT         = 480,
    parameter LVAL_HIGH         = 800,
    parameter LVAL_LOW          = 100
    
)(

    input clk,
    input rst,
    input en,
    
    output reg fval,
    output reg dval,
    output reg lval,
    
    output lval_negedge_out,
    output fval_posedge_out
    
    );

// Registers

reg [31:0] counter_fval = 0; 
reg [31:0] counter_lval = 0;
reg [31:0] counter_dval = 0;       
reg [31:0] counter_fval2lval = 1;
reg [31:0] counter_lval2dval = 1;               
reg [31:0] line_counter = 0;

reg fval_samp;
reg lval_samp;
reg en_samp; 

wire fval_posedge; 
wire lval_negedge;
wire en_posedge;

assign lval_negedge_out = lval_negedge;
assign fval_posedge_out = fval_posedge;

// Posedge and negedge assignments
assign fval_posedge = fval && !fval_samp; 
assign lval_negedge =  !lval && lval_samp; 
assign en_posedge = en && !en_samp; 

always @(posedge clk or posedge rst) begin
    
    if (rst == 1) begin
    
      counter_fval <= 0;
      counter_lval <= 0;
      counter_dval <= 0;
      counter_fval2lval <= 1;
      counter_lval2dval <= 1;
      line_counter <= 0;
      
      fval <= 1'b0;
      lval <= 1'b0;
      dval <= 1'b0;

    end else begin

        
        //Make the signals start with high logic 
        
        if (en_posedge) begin
            fval <= 1; 
            counter_fval <= 1;      // Every posedge en, reset counter_fval and make fval high logic.    
        end    
        
        // Store en signal
        en_samp <= en;
        
        
        if (lval_negedge) begin
            if (line_counter >= (ROW_COUNT - 1)) begin        
                lval <= 0;
                dval <= 0;
                fval <= 1'b0;            
            end else begin
                line_counter <= line_counter + 1;
                
                lval <= 1;
                counter_dval <= 0;
                counter_lval <= 0;
            end              
        end    
        
        // Store lval signal
        lval_samp <= lval;  
        
        
        // Reset line_counter
        if (fval_posedge) begin
            line_counter <= 0;
            counter_fval <= 1;
            counter_lval <= 0;
            counter_dval <= 0;
  
            counter_fval2lval <= 1;
            counter_lval2dval <= 1;
        end

        // Store fval
        fval_samp <= fval; 
        
        
        // If enable bit is high, create fval signal. 
        if (en == 1) begin
            if (counter_fval == (CLK_FREQ_HZ / FPS)) begin   
                fval <= 1'b1;
                counter_fval <= 1;
            end else
            counter_fval <= counter_fval + 1;
        end
        
        
        // If fval signal exits, create lval signal.
        if (fval == 1) begin
            if (counter_fval2lval >= FVAL2LVAL) begin
                counter_lval <= counter_lval + 1;  
                if (counter_lval == (LVAL_HIGH + LVAL_LOW)) begin 
                    lval <= 1'b1;
                    counter_lval <= 1;
                end else if (counter_lval >= LVAL_HIGH) begin
                    lval <= 1'b0; 
                end else
                    lval <= 1;       
            end else begin
                lval <= 1'b0;  //If lval_allow is low, lval is low. 
                counter_fval2lval <= counter_fval2lval + 1;      
            end
        end else begin
            lval <= 1'b0;
            counter_fval2lval <= 1; 
        end 
    
    
        // If lval signals exist, create dval signal.
        if (lval == 1) begin
            if (counter_lval2dval >= LVAL2DVAL) begin
                if (counter_dval == DVAL_HIGH) begin
                    dval <= 1'b0;
                    //counter_dval <= 1;  
                end else begin
                    counter_dval <= counter_dval + 1;
                    dval <= 1'b1;
                end      
            end else begin
                dval <= 1'b0;
                counter_lval2dval <= counter_lval2dval + 1;    
            end        
        end else begin
            dval <= 1'b0;
            counter_lval2dval <= 1;
        end
        
    end
end
endmodule
