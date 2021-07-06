
/*
Author: Ali Ufuk Ercan
Description: Generation of the patterns.
Version: 1.00
*/

module frame_pattern_gen #(
    
    parameter DVAL_HIGH = 640,
    parameter ROW_COUNT = 480
    
)(
    
    input clk,
    input rst,
    input [2:0] sel,
    input dval,
    
    input lval_negedge,
    input fval_posedge,
    
    output reg [7:0] pix_value
    
    );
 
//Registers
reg [31:0] line_counter = 0; 
reg [31:0] counter_dval = 0;
    
// Gradient registers
reg [31:0] repeat1 = 1;
reg [31:0] stretch = 1;
reg [31:0] reg_pix_value;
reg [31:0] column = 0;

// Registers and wires for instantiation
reg [31:0] width;
reg [31:0] height;
wire [1:0] pix_value1;    

// Instantiation for LOGO
pixel_memory #(.frame_width(DVAL_HIGH),.frame_height(ROW_COUNT)) 
PIX_MEM (
    .width(width), 
    .height(height), 
    .pix_value(pix_value1)
);

always @(posedge clk or posedge rst) begin
    
    if (rst == 1) begin
   
      column <= 1; 
      repeat1 <= 1;
      stretch <= 1;
      reg_pix_value <= 8'b00000000;
      line_counter <= 0;
      counter_dval <= 0;
      width <= 0;
      height <= 0;
        
    end else begin
    

        // Resets
        if (lval_negedge) begin
            if (line_counter >= (ROW_COUNT - 1)) begin        
                column <= 1;
            end else begin
                line_counter <= line_counter + 1;
                counter_dval <= 0;
                column <= 1;
                pix_value <= 0;                 
                reg_pix_value <= 0;
                
            end              
        end            
        
        
       
        if (fval_posedge) begin
            
            line_counter <= 0;
            column <= 1;
            repeat1 <= 1;
            pix_value <= 0;          
            reg_pix_value <= 0;
            counter_dval <= 0;
            
            width <= 0;
            height <= 0;
        end
        
        
        if (dval) begin
            counter_dval <= counter_dval + 1;
        end else 
            pix_value <= 8'b00000000;
    
        ///////////////////////////
        // Creating the patterns
        //////////////////////////
        
        // Full Black
        if (sel == 3'b000) begin
            if (dval)
                pix_value <= 8'b00000000; 
        end
        
        // Full White
        if (sel == 3'b001) begin
            if (dval)
                pix_value <= 8'b11111111;
        end
        
        // Gradient
        if (sel == 3'b010) begin
            if (stretch >= DVAL_HIGH) begin 
                if (counter_dval == column) begin
                    pix_value <= reg_pix_value;
                    column <= column + 1;
                    if (counter_dval % repeat1 == 0)
                        reg_pix_value <= reg_pix_value + 1;                   
                end
            end else
                repeat1 <= repeat1 + 1;    
        end
        
        // Checkers
        if (sel == 3'b011) begin
            
            if (line_counter < (ROW_COUNT / 8) || 
            (line_counter >= (ROW_COUNT / 8 * 2) && line_counter < (ROW_COUNT / 8 * 3)) || 
            (line_counter >= (ROW_COUNT / 8 * 4) && line_counter < (ROW_COUNT / 8 * 5)) || 
            (line_counter >= (ROW_COUNT / 8 * 6) && line_counter < (ROW_COUNT / 8 * 7)) ) begin
                
                if (counter_dval <=  DVAL_HIGH / 8) begin
                    pix_value <= 8'b00000000;   
                end else if (counter_dval <= DVAL_HIGH / 8 * 2) begin
                    pix_value <= 8'b11111111; 
                end else if (counter_dval <= DVAL_HIGH / 8 * 3) begin
                    pix_value <= 8'b00000000; 
                end else if (counter_dval <= DVAL_HIGH / 8 * 4) begin
                    pix_value <= 8'b11111111; 
                end else if (counter_dval <= DVAL_HIGH / 8 * 5) begin
                    pix_value <= 8'b00000000; 
                end else if (counter_dval <= DVAL_HIGH / 8 * 6) begin
                    pix_value <= 8'b11111111; 
                end else if (counter_dval <= DVAL_HIGH / 8 * 7) begin
                    pix_value <= 8'b00000000; 
                end else
                    pix_value <= 8'b11111111; 
            
            end else if ((line_counter >= (ROW_COUNT / 8) && line_counter < (ROW_COUNT / 8 * 2)) || 
            (line_counter >= (ROW_COUNT / 8 * 3) && line_counter < (ROW_COUNT / 8 * 4)) ||
            (line_counter >= (ROW_COUNT / 8 * 5) && line_counter < (ROW_COUNT / 8 * 6)) || 
            (line_counter >= (ROW_COUNT / 8 * 7) && line_counter < ROW_COUNT)) begin
                
                if (counter_dval <=  DVAL_HIGH / 8) begin
                    pix_value <= 8'b11111111;   
                end else if (counter_dval <= DVAL_HIGH / 8 * 2) begin
                    pix_value <= 8'b00000000; 
                end else if (counter_dval <= DVAL_HIGH / 8 * 3) begin
                    pix_value <= 8'b11111111; 
                end else if (counter_dval <= DVAL_HIGH / 8 * 4) begin
                    pix_value <= 8'b00000000; 
                end else if (counter_dval <= DVAL_HIGH / 8 * 5) begin
                    pix_value <= 8'b11111111; 
                end else if (counter_dval <= DVAL_HIGH / 8 * 6) begin
                    pix_value <= 8'b00000000; 
                end else if (counter_dval <= DVAL_HIGH / 8 * 7) begin
                    pix_value <= 8'b11111111; 
                end else
                    pix_value <= 8'b00000000; 
            end else begin
                    pix_value <= 8'b11111111;
            end
        end
        
        // 3D-1
        
        // 3D-2
        
        // SHAPES GEO will be added.
        
        //LOGO
        if (sel == 3'b111) begin
            if (dval == 1) begin
                width <= counter_dval;
                height <= line_counter;
                pix_value <= pix_value1;    
            end               
        end  
        
        
    end
end

// Combinational Block for gradient
always @(clk) begin
  
    stretch = repeat1 * 255;

end

endmodule
