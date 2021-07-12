
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
integer cubes;

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

initial begin

// Open the files
full_black = $fopen("full_black.pgm","wb");
full_white = $fopen("full_white.pgm","wb");
gradient = $fopen("gradient.pgm","wb");
checkers = $fopen("checkers.pgm","wb");
cubes = $fopen("cubes.pgm","wb");
logo = $fopen("logo.pgm","wb");

headers(full_black);
@(posedge clk);
headers(full_white);
@(posedge clk);
headers(gradient);
@(posedge clk);
headers(checkers);
@(posedge clk);
headers(cubes);
@(posedge clk);
headers(logo);

end

// Store pixel values by using state machines.
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
            end else  
                state <= fval_val;    
        end
        
        endcase
        
    end

end

// Reset j every fval posedge
always @(posedge fval) begin
    j <= 0;
end

// Reset i every lval posedge
always @(posedge lval) begin
    i <= 0;
end

// Write the stored values to the files.
always @(negedge fval) begin

    if (en && !fval)  begin  
        
        if (sel == 3'b000) begin
            
            for (y = 0; y <= j; y = y + 1) begin
                for (x = 0; x < i; x = x+ 1) begin
                    $fwriteb(full_black,"%c",temp_memory[y][x]); 
                end
            end
            $fclose(full_black);
       
        end else if (sel == 3'b001) begin
            
            for (y = 0; y <= j; y = y + 1) begin
                for (x = 0; x < i; x = x+ 1) begin
                    $fwriteb(full_white,"%c",temp_memory[y][x]); 
                end
            end
            $fclose(full_white);
                 
        end else if (sel == 3'b010) begin
            
            for (y = 0; y <= j; y = y + 1) begin
                for (x = 0; x < i; x = x+ 1) begin
                    $fwriteb(gradient,"%c",temp_memory[y][x]); 
                end
            end
            $fclose(gradient);
            
        end else if (sel == 3'b011) begin
                     
            for (y = 0; y <= j; y = y + 1) begin
                for (x = 0; x < i; x = x+ 1) begin
                    $fwriteb(checkers,"%c",temp_memory[y][x]); 
                end
            end
            $fclose(checkers);
              
        end else if (sel == 3'b110) begin
            
            for (y = 0; y <= j; y = y + 1) begin
                for (x = 0; x < i; x = x+ 1) begin
                    $fwriteb(cubes,"%c",temp_memory[y][x]); 
                end
            end
            $fclose(cubes);
            
        end else if (sel == 3'b111) begin
            
            for (y = 0; y <= j; y = y + 1) begin
                for (x = 0; x < i; x = x+ 1) begin
                    $fwriteb(logo,"%c",temp_memory[y][x]); 
                end
            end
            $fclose(logo);
            
        end   
    end   
    
end

 
endmodule
