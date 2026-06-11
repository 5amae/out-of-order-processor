`timescale 1ns / 1ps
module ReserveStation(
    input clk, rst,
    input issue_en, // some new instruction is entering this station, check it out if it has all the stuff that it needs, if not then place it in a station
    input [4:0] ALUCtl, // the reservation station will recieve the command, like div mul shift etc, based on this it will place in a certain station
    input [31:0] number_1, // it will recieve the first number if that number is ready , suppose r1, but if r1 is not ready it wont pass forward, it will wait for it
    input [31:0] number_2, // same
    input [2:0] rs1_tag, // it will recieve the tag from the register aliasing table for
    input [2:0] rs2_tag,  // both the numbers, if one is ready or busy or something
    input bus_en, // if this is high then some number is being sent
    input [2:0] bus_tag, // the tag for that thing we are waiting for
    input [31:0] bus_data, // that data for that certain thing
    input clear_reserve, // once all the computation is done, this clears the entire station and tells the answer on the bus
    
    
    
    output reg busy, // if this particular station is busy then it sends back a busy signal to the CONTROL unit signifying that this station is not up for storing anything
    output ready_for_exec, //tell the alu that the numbers are all ready and u can take them to perform the task
    output reg [4:0] ALU_control, // what the alu should do
    output reg [31:0] V1,V2// the two numbers

    );
    
    reg [2:0] tag1, tag2;
    assign ready_for_exec = (busy ==1 && tag1==0 && tag2 ==0)? 1'b1 : 1'b0;
    
    
     
     always@( posedge clk or posedge rst)
     begin 
         if(~rst)
             begin
             V1 <= 32'b0;
             V2 <= 32'b0;
             busy <=0;
             tag1 <=3'b0;
             tag2 <=3'b0;
           
         end
         else begin
         
         if(clear_reserve ==1)begin
         busy <= 0;
         end
         
         else if(issue_en ==1 && busy ==0) begin
         
         tag1 <= rs1_tag;  // give the tag recieved from dispatcher
         V1 <=  number_1;// give the number again from dispatcher
         tag2 <= rs2_tag;  //give both to the ALU and let it do its stuff
         V2 <=  number_2;
         busy <= 1'b1;   // this means this reservation station is busy
         ALU_control <= ALUCtl;
         end
         
         else if(bus_en ==1 && busy ==1)
         begin
             if(tag1 !=0 && (tag1 == bus_tag))begin
             V1 <= bus_data;
              tag1 <= 3'b0; // this means that if the bus information is ok and is ready according 
             end //and that particular tag is sent, so that tag is cleared and then that info is stored
          
             if(tag2 !=0 && (tag2 == bus_tag))begin
             V2 <= bus_data;// same thing with up
              tag2 <= 3'b0;
             end 
         end
         
         end
         
          
      end   
endmodule
