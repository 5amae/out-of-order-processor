`timescale 1ns / 1ps
//this pc is for incrementing the required address for the particular instruction in instruction memory,
//every instruction has a dedicated pc each of which are separated by 4 counts, hence the pc increments or decrements with 4
// each value of the pc like 0x04 holds 8 bits, thus 4 locations of the pc will contain 32 bits
//in case any branch or jump instruction are included then branch predictors would be needed which is out of the scope of this processor
//but all normal R I L S instructions do not need any such predictions hence there is no jumping additions or the pc
module PC (
    input clk,
    input rst,
    input [31:0] pc_i,
    output reg [31:0] pc_o
);
always @(posedge clk ) begin
	if (~rst)
		pc_o <=32'b0;
	else
		pc_o <= pc_i;
end
endmodule

