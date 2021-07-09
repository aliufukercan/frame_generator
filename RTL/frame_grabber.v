`timescale 1ns / 1ps

/*
Author: Ali Ufuk Ercan
Description: Writes pixel values to file.
Version: 1.00
*/

module frame_grabber #(

    parameter WIDTH             = 640,
    parameter HEIGHT            = 480

)(
    
    input clk,
    input rst,
    input fval,
    input lval,
    input dval,
    input [2:0] sel,
    input en,
    input [7:0] pix_data
    );
    
parameter idle = 2'b00;
parameter fval_val = 2'b01;
parameter lval_val = 2'b10;
reg [1:0] state;

reg reset; 
reg [7:0] temp_memory [0:4095][0:4095];
reg [31:0] i;
reg [31:0] j;

// For loop registers
reg [31:0] x;
reg [31:0] y;

// For writing to file
integer full_black;
integer full_white;
integer gradient;
integer checkers;
integer logo;
integer squares_3d;


initial begin

// Open the files
full_black = $fopen("D:/Vivado Projects/full_black.pgm","wb");
full_white = $fopen("D:/Vivado Projects/full_white.pgm","wb");
gradient = $fopen("D:/Vivado Projects/gradient.pgm","wb");
checkers = $fopen("D:/Vivado Projects/checkers.pgm","wb");
squares_3d = $fopen("D:/Vivado Projects/squares_3d.pgm","wb");
logo = $fopen("D:/Vivado Projects/logo.pgm","wb");

//headers(full_black);
headers(logo);
end

// Create file headers
task headers (
    
    input integer file
    
);
    begin
    $fstrobe(file,"P5");
    @(posedge clk);
    $fwrite(file,WIDTH);
    $fwrite(file," ");
    $fstrobe(file,HEIGHT);
    $fstrobe(file,"255");
    end
    
endtask


always @(posedge clk or posedge rst) begin
    
    if (rst == 1) begin
        
        state <= idle;
        reset <= 1;
        i <= 0;
        j <= 0;
        
    end else begin 
        
        case (state)
        
        idle: begin
            
            reset <= 1;
            i <= 0;
            j <= 0;
            
            if (fval)
                state <= fval_val;
            else
                state <= idle;
        end
        
        fval_val: begin
            
            if (fval) begin
                if (lval) begin
                    state <= lval_val;
                    if (reset) begin 
                        j <= 0;
                        reset <= 0;
                    end else
                        j <= j + 1;    
                end else
                    state <= fval_val;
            end else
                state <= idle;            
        end
        
        lval_val: begin
            
            if (lval) begin
                if (dval) begin
                    temp_memory [j][i] <= pix_data;
                    i <= i + 1;
                    state <= lval_val;
                end else
                    state <= lval_val;
            end else begin 
                state <= fval_val;
                i <= 0;
            end    
        end
        
        endcase
    end

end

always @(posedge clk)begin
     
     if (en && !fval)   
        for (y = 0; y <= j; y = y + 1) begin
            for (x = 0; x <= i; x = x+ 1) begin
                $fwriteb(logo,"%c",temp_memory[y][x]); 
            end
        end
end

//always @(negedge fval)
//    allow_write <= 1;

//always @(posedge fval)
//    allow_write <= 0;
            
//always @(posedge clk) begin
//if(allow_write) begin    
//   if (sel == 3'b000) begin
        
//        headers(full_black);
//        for (y = 0; y <= j; y = y + 1) begin
//            for (x = 0; x <= i; x = x+ 1) begin
//                $fwriteb(full_black,"%c",temp_memory[y][x]); 
//            end
//        end
//        $fclose(full_black);
        
//    end else if (sel == 3'b001) begin
        
//        headers(full_white);
//        for (y = 0; y <= j; y = y + 1) begin
//            for (x = 0; x <= i; x = x+ 1) begin
//                $fwriteb(full_white,"%c",temp_memory[y][x]); 
//            end
//        end
//        $fclose(full_white);
        
//    end else if (sel == 3'b010) begin
        
//        headers(gradient);
//        for (y = 0; y <= j; y = y + 1) begin
//            for (x = 0; x <= i; x = x+ 1) begin
//                $fwriteb(gradient,"%c",temp_memory[y][x]); 
//            end
//        end
//        $fclose(gradient);
        
//    end else if (sel == 3'b011) begin
        
//        headers(checkers);           
//        for (y = 0; y <= j; y = y + 1) begin
//            for (x = 0; x <= i; x = x+ 1) begin
//                $fwriteb(checkers,"%c",temp_memory[y][x]); 
//            end
//        end
//        $fclose(checkers);
        
//    end else if (sel == 3'b110) begin
        
//        headers(squares_3d); 
//        for (y = 0; y <= j; y = y + 1) begin
//            for (x = 0; x <= i; x = x+ 1) begin
//                $fwriteb(squares_3d,"%c",temp_memory[y][x]); 
//            end
//        end
//        $fclose(squares_3d);
        
//    end else if (sel == 3'b111) begin
        
//        headers(logo); 
//        for (y = 0; y <= j; y = y + 1) begin
//            for (x = 0; x <= i; x = x+ 1) begin
//                $fwriteb(logo,"%c",temp_memory[y][x]); 
//            end
//        end
//        $fclose(logo);
    
    //end   
//end    
//end

 
endmodule
