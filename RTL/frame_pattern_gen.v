
/*
Author: Ali Ufuk Ercan
Description: Generation of the patterns.
Version: 1.03
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
reg [31:0] line_counter; 
reg [31:0] counter_dval;
    
// Gradient registers
reg [31:0] repeat1;
wire [31:0] stretch;
reg [31:0] reg_pix_value;

// Registers and wires for instantiation
reg [31:0] width;
reg [31:0] height;
wire [1:0] pix_value_logo;    
wire [1:0] pix_value_cubes;
wire [1:0] pix_value_choco_bar;
wire [7:0] decoded_pix_value_logo;
wire [7:0] decoded_pix_value_cubes;
wire [7:0] decoded_pix_value_choco_bar;

//Calculate stretch.
assign stretch = repeat1 * 255; 

// Instantiation for LOGO
pixel_memory_logo #(.frame_width(DVAL_HIGH),.frame_height(ROW_COUNT))  
PIX_MEM_LOGO (
    .width(width), 
    .height(height),
    .pix_value(pix_value_logo)
);

// Instantiation for cubes
pixel_memory_cubes #(.frame_width(DVAL_HIGH),.frame_height(ROW_COUNT)) 
PIX_MEM_CUBES (
    .width(width), 
    .height(height), 
    .pix_value(pix_value_cubes)
);

// Instantiation for choco_bar
pixel_memory_choco_bar #(.frame_width(DVAL_HIGH),.frame_height(ROW_COUNT)) 
PIX_MEM_CHOCO_BAR (
    .width(width), 
    .height(height), 
    .pix_value(pix_value_choco_bar)
);

// Decode logo pixel values
decoder DECODER_LOGO (
    .pix_data(pix_value_logo),
    .sel(sel),
    .decoded_pix_data(decoded_pix_value_logo)
);

// Decode cubes pixel values
decoder DECODER_CUBES (
    .pix_data(pix_value_cubes),
    .sel(sel),
    .decoded_pix_data(decoded_pix_value_cubes)    
);

// Decode choco_bar pixel values
decoder DECODER_CHOCO_BAR (
    .pix_data(pix_value_choco_bar),
    .sel(sel),
    .decoded_pix_data(decoded_pix_value_choco_bar)    
);

always @(posedge clk or posedge rst) begin
    
    if (rst == 1) begin
   
      repeat1 <= 1;
      reg_pix_value <= 0;
      line_counter <= 0;
      counter_dval <= 0;
      width <= 0;
      height <= 0;
        
    end else begin
    

        // Resets
        if (lval_negedge) begin
 
            line_counter <= line_counter + 1;
            counter_dval <= 0;
            pix_value <= 0;                 
            reg_pix_value <= 0;
               
        end            
        
        
       
        if (fval_posedge) begin
            
            line_counter <= 0;
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
            pix_value <= 0;
             
               
        ///////////////////////////
        // Creating the patterns
        //////////////////////////
        
        // Straps
        if (sel == 3'b000) begin
            
            if (line_counter < (ROW_COUNT / 16) ||
            (line_counter >= (ROW_COUNT * 4 / 16) && line_counter < (ROW_COUNT * 5 / 16)) ||
            (line_counter >= (ROW_COUNT * 8 / 16) && line_counter < (ROW_COUNT * 9 / 16)) ||
            (line_counter >= (ROW_COUNT * 12 / 16) && line_counter < (ROW_COUNT * 13 / 16)) ) begin
            
                if (dval)
                    pix_value <= 8'b00000000; 
                    
            end else if (line_counter < (ROW_COUNT * 2 / 16) ||
            (line_counter >= (ROW_COUNT * 5 / 16) && line_counter < (ROW_COUNT * 6 / 16)) ||
            (line_counter >= (ROW_COUNT * 9 / 16) && line_counter < (ROW_COUNT * 10 / 16)) ||
            (line_counter >= (ROW_COUNT * 13 / 16) && line_counter < (ROW_COUNT * 14 / 16)) ) begin
            
                if (dval)
                    pix_value <= 8'b01010101;
            
            end else if (line_counter < (ROW_COUNT * 3 / 16) ||
            (line_counter >= (ROW_COUNT * 6 / 16) && line_counter < (ROW_COUNT * 7 / 16)) ||
            (line_counter >= (ROW_COUNT * 10 / 16) && line_counter < (ROW_COUNT * 11 / 16)) ||
            (line_counter >= (ROW_COUNT * 14 / 16) && line_counter < (ROW_COUNT * 15 / 16)) ) begin
            
                if (dval)
                    pix_value <= 8'b10101010;
                
            end else if (line_counter < (ROW_COUNT * 4 / 16) ||
            (line_counter >= (ROW_COUNT * 7 / 16) && line_counter < (ROW_COUNT * 8 / 16)) ||
            (line_counter >= (ROW_COUNT * 11 / 16) && line_counter < (ROW_COUNT * 12 / 16)) ||
            (line_counter >= (ROW_COUNT * 15 / 16) && line_counter < ROW_COUNT) ) begin
            
                if (dval)
                    pix_value <= 8'b11111111;
                    
            end
            
        end
        
        // Choco_bar
        if (sel == 3'b001) begin
            if (dval == 1) begin
                width <= counter_dval;
                height <= line_counter;
                pix_value <= decoded_pix_value_choco_bar;    
            end        
        end
        
        // Gradient
        if (sel == 3'b010) begin
            if (stretch >= DVAL_HIGH) begin 
                if (dval) begin
                    pix_value <= reg_pix_value;
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
        
        // Cubes
        if (sel == 3'b110) begin
            if (dval == 1) begin
                width <= counter_dval;
                height <= line_counter;
                pix_value <= decoded_pix_value_cubes;    
            end               
        end
        
        // SHAPES GEO will be added.
        
        //LOGO
        if (sel == 3'b111) begin
            if (dval == 1) begin
                width <= counter_dval;
                height <= line_counter;
                pix_value <= decoded_pix_value_logo;    
            end               
        end  
        
        
    end
end

endmodule
