
/*
Author: Ali Ufuk Ercan
Description: Reading, encoding and storing the pixel values from given file.
Version: 1.00
*/
 
module pixel_memory #(

    parameter frame_width       = 640,
    parameter frame_height      = 480      

)(
    input [31:0] width,
    input [31:0] height,
    output reg [1:0] pix_value
    
    );

reg [7:0] temp_memory [0:frame_height - 1] [0:frame_width - 1];
reg [1:0] memory [0:frame_height - 1] [0:frame_width - 1];   
reg [31:0] j;
reg [31:0] i;


initial begin

$readmemb("pgm_mikro_tasarim_string.txt",temp_memory);

for (j = 0; j < frame_height; j = j + 1) begin
    for (i = 0; i < frame_width; i = i + 1) begin
        
        if (temp_memory[j][i] == 8'b00000000)
            memory[j][i] = 2'b00;
        else if (temp_memory[j][i] == 8'b11111111)  
            memory[j][i] = 2'b11;
        else
            memory[j][i] = 2'b01;       
    end
end


end 

// Combinational block
always @(width or height)
pix_value = memory[height][width];  // column row 

endmodule



		