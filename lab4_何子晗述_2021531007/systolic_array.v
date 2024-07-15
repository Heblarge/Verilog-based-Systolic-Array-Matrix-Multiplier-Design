`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/10 23:47:41
// Design Name: 
// Module Name: systolic_array
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


module systolic_array#(
    parameter X_COLS = 16,
    parameter W_COLS = 9,
    parameter W_ROWS = 7,
    parameter DATA_WIDTH = 32
) (
    input clk,
    input rst,
    input [DATA_WIDTH*W_COLS-1:0] X,
    input [DATA_WIDTH*W_COLS*W_ROWS-1:0] W,
    output [DATA_WIDTH*W_ROWS-1:0] Y,
    output reg valid,
    output reg done
);

//*****************************
// You shoud overwrite this

reg [31:0] count = 0;//use count to mark the clock cycle

//check valid and done
always@(posedge clk) begin
    if (rst) begin
        valid <= 0;
        done <= 0;
    end
    else begin
        if(count >= W_ROWS +W_COLS)begin
            valid <=1;
        end
        else begin
            valid <= 0 ;
        end
        if(count >= W_ROWS +W_COLS+X_COLS)begin
            done <= 1;
        end
        else begin
            done <= 0;
        end
        count = count + 1;
    end
end

  //assign w_mat
  wire[DATA_WIDTH-1:0] W_mat[W_ROWS-1:0][W_COLS-1:0];
  genvar i,j;
  generate
    for (i = 0; i < W_ROWS; i = i + 1) begin
      for (j = 0; j < W_COLS; j = j + 1) begin
          assign W_mat[i][j] = W[(i*W_COLS+j+1)*DATA_WIDTH-1:(i*W_COLS+j)*DATA_WIDTH];
      end
    end
  endgenerate 

//assign every row of x in an x_mat
wire [DATA_WIDTH-1:0] X_mat[W_COLS-1:0];
genvar k;
  generate
    for(k=0; k<W_COLS ; k = k+1)begin
      assign X_mat[k] = X[(k+1)*DATA_WIDTH-1:k*DATA_WIDTH];
    end
  endgenerate

//put every row of x in a the right place so that clock cycle is matched
reg [DATA_WIDTH-1:0] X_input_mat[W_COLS-1:0][X_COLS+W_COLS-2:0];
integer in_row,rstx,rsty;
always@(*)begin
  if(rst)begin
    for(rstx = 0; rstx < W_COLS; rstx=rstx+1)begin
      for(rsty = 0; rsty < X_COLS+W_COLS-1; rsty = rsty+1)begin
        X_input_mat[rstx][rsty]<=0;
      end
    end
  end
  else begin
    for (in_row=0; in_row<W_COLS; in_row=in_row+1)begin
      X_input_mat[in_row][in_row+count-1] <= X_mat[in_row];
    end
  end
end


// connect PEs
wire[DATA_WIDTH-1:0] X_connect [W_COLS-1:0][W_ROWS:0];
wire[DATA_WIDTH-1:0] Y_connect [W_COLS:0][W_ROWS-1:0];
genvar pe_i, pe_j;
generate
  for (pe_i = 0; pe_i < W_COLS; pe_i = pe_i + 1) begin
    for (pe_j = 0; pe_j < W_ROWS; pe_j = pe_j + 1) begin
      pe #(.DATA_WIDTH(DATA_WIDTH)) PEs  (
        .clk(clk),
        .rst(rst),
        .w(W_mat[pe_j][pe_i]),
        .x_in(X_connect[pe_i][pe_j]),
        .y_in(Y_connect[pe_i][pe_j]),
        .x_out(X_connect[pe_i][pe_j+1]),
        .y_out(Y_connect[pe_i+1][pe_j])
      );
    end
  end
endgenerate

//PEs connect to X input
genvar Xin_k;
generate 
    for (Xin_k = 0; Xin_k < W_COLS; Xin_k = Xin_k + 1)begin
        assign X_connect[Xin_k][0]=X_input_mat[Xin_k][count-1];
    end
endgenerate 

//PEs connect to Y input
genvar Yin_k;
generate 
    for (Yin_k = 0; Yin_k < W_ROWS; Yin_k = Yin_k + 1)begin
        assign Y_connect[0][Yin_k]=0;
    end
endgenerate 

//PEs connect to Y output
reg [DATA_WIDTH-1:0] y_output_mat [X_COLS+W_ROWS-2:0][W_ROWS-1:0];
reg [DATA_WIDTH*W_ROWS-1:0] y_reg;
integer p,q;
always @(*)begin
    if(count>=W_COLS+1)begin
        for(p=0;p<count-W_COLS && count<W_COLS+W_ROWS+X_COLS+1;p=p+1)begin
            y_output_mat[count-W_COLS-1][p]<=Y_connect[W_COLS][p];                
        end
    end
    if (count >= W_ROWS +W_COLS+1 && count<=W_COLS+W_ROWS+X_COLS) begin
        for (q = 0; q < W_ROWS; q = q + 1) begin
            y_reg[(W_ROWS-q-1)*DATA_WIDTH+: DATA_WIDTH] <= y_output_mat[count-W_COLS-2-q][W_ROWS-q-1];
        end           
    end  
end
assign Y = y_reg;

//*****************************

endmodule
