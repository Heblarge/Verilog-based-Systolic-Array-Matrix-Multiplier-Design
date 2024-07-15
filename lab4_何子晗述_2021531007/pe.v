`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/10 23:48:09
// Design Name: 
// Module Name: pe
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pe #(
    parameter DATA_WIDTH = 32
) (
    input clk,
    input rst,
    input [DATA_WIDTH-1:0] w,
    input [DATA_WIDTH-1:0] x_in,
    input [DATA_WIDTH-1:0] y_in,
    output reg [DATA_WIDTH-1:0] x_out,
    output reg [DATA_WIDTH-1:0] y_out
);

//*****************************
// You shoud overwrite this
always@(posedge clk) begin
    if (rst) begin
        x_out <= 0;
        y_out <= 0;
    end
    else begin
        x_out <= x_in;
        y_out <= x_in * w + y_in;
    end
end
//*****************************

endmodule
