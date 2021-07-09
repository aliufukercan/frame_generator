
/*
Author: Ali Ufuk Ercan
Description: Reading, encoding and storing the pixel values from given file.
Version: 1.00
*/
 
module pixel_memory_logo #(

    parameter frame_width       = 640,
    parameter frame_height      = 480      

)(
    input [31:0] width,
    input [31:0] height,
    output reg [1:0] pix_value
    
    );

reg [1:0] memory [0:frame_height - 1] [0:frame_width - 1];   


initial begin
    $readmemb("pgm_mikro_tasarim_string.txt",memory);
end        


// Combinational block
always @(width or height)
    pix_value = memory[height][width];  // column row 

endmodule



		