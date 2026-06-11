`timescale 1ns / 1ps
module RegAlias(
    input clk, rst,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [2:0] rd_tag,
    input issue_en,
    input bus_en,
    input [2:0] bus_tag,
    output [2:0] rs1_tag,
    output [2:0] rs2_tag,
    output rs1_busy,
    output rs2_busy
    );
    
    reg [31:0] busy; // 32 registers, each have bsuy bit to show whether it is busy or not
    reg [2:0] tag [0:31]; // if they are busy then that tag is given that reservation table address
    // ex if r5 is busy in reservation station 4 then
    // busy[5] = 1
    // tag[5] = 100
    integer i;
    
    assign rs1_busy = (rs1 == 0)? 1'b0 : busy[rs1];
    assign rs1_tag = tag[rs1];// just if rs1 is 0 then 0 , or else just tell whether it is busy or not
    // checking the table, again if r5 was initially busy then busy[5] will be 1
    // and the tag is just read based on what is asked
    
    assign rs2_busy = (rs2 == 0)? 1'b0 : busy[rs2];
    assign rs2_tag = tag[rs2];
    
    always@(posedge clk or posedge rst)
    begin
    if(~rst)begin
        busy <= 32'b0;
        for(i=0 ; i<32; i=i+1)
        begin 
        tag[i] <= 3'b0; // just reset all the tags to 0
        end
    end
    else
    begin
        if(bus_en) begin
        for(i=1; i<32 ;i=i+1)begin
        if(busy[i]&& (tag[i]==bus_tag))
        busy[i] <= 1'b0; // if the bus is broadcasting , and the tag that the bus is associated with
        //is matching, AND initially that tag was busy then assign it to 0, to say that the processing is done
        end
    end
    
    if(issue_en && (rd!= 0))
    begin
        busy[rd] <= 1'b1;// it receieves the bit from the dispatcher, if the destination register is no 0
        tag[rd] <= rd_tag; // then it assigns that corresponding tag of that register as whatever station it was sent to
        // that register is busy and is being computed
        
    end
   end
    end
        
endmodule
