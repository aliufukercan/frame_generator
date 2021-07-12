`timescale 1ns / 1ps

/*
Author: Ali Ufuk Ercan
Description: Decodes the given data.
Version: 1.00
*/

module decoder(
    
    input [1:0] pix_data,
    input [2:0] sel,
    output reg [7:0] decoded_pix_data
    );
    
        
 //Combinational Block for decoding
always @(*) begin
    
    if (sel == 3'b111) begin                    // LOGO Decode
        
        if (pix_data == 2'b00) 
            decoded_pix_data = 8'b00000000;
        else if (pix_data == 2'b11)
            decoded_pix_data = 8'b11111111;
        else 
            decoded_pix_data = 8'b01100100;    
    
    end else if (sel == 3'b110) begin                 // Cubes Decode
        
        if (pix_data == 2'b00) 
            decoded_pix_data = 8'b00000000;
        else if (pix_data == 2'b11)
            decoded_pix_data = 8'b10010110;
        else 
            decoded_pix_data = 8'b00110010; 
    
    end else 
        decoded_pix_data = 8'b00000000;        
end   
    
  
endmodule
