`timescale 1ns / 1ps
module LoadStoreBuffer(
    input clk, rst,
    input issue_en, // some new instruction is entering this station, check it out if it has all the stuff that it needs, if not then place it in a station
    input is_load,  // whether the instruction is a load or store command
    input is_store,
    
    
    
    
    
    input [31:0] number_1, // it will recieve the first number if that number is ready , suppose r1, but if r1 is not ready it wont pass forward, it will wait for it
    input [31:0] number_2, // same
    input [31:0] imm_in, // if it is load then the offset, and if it is store then maybe the immediate offset
    //essentially
    
    
    input [2:0] rs1_tag, // it will recieve the tag from the register aliasing table for
    input [2:0] rs2_tag,  // both the numbers, if one is ready or busy or something
    input bus_en, // if this is high then some number is being sent
    input [2:0] bus_tag, // the tag for that thing we are waiting for
    input [31:0] bus_data, // that data for that certain thing
    input clear_reserve, // if we get the data for that certain thing then we should clear he tag at that place
    
    output memRead,// for load
    output memWrite,// for store
    output [31:0] address,// whichever adress needs ti be read
    output [31:0] writeData,//the input we want to write at that address
    input [31:0] readData,// whatever was read during load
    
    output reg busy, // if this particular station is busy then it sends back a busy signal to the CONTROL unit signifying that this station is not up for storing anything
    output ready_for_exec, //tell the alu that the numbers are all ready and u can take them to perform the task
    output [31:0] out_data // whatever comes out of the load in data memory

    );
    
    reg [31:0] V1; // address to be stored
    reg [31:0] V2; //data to be stored
    reg [31:0] imm;//offset
   
    reg op_load; // whether a load or store
    reg  op_store;
    reg [2:0] tag1, tag2; // tags for the two values whther they are ready or not
    assign ready_for_exec = (busy ==1 && tag1==0 && tag2 ==0 && (op_load || op_store))? 1'b1 : 1'b0;
    
    
     
     always@( posedge clk or posedge rst)
     begin 
         if(~rst)
             begin
             V1 <= 32'b0;
             V2 <= 32'b0;
             busy <=0;
             tag1 <=3'b0;
             tag2 <=3'b0;
             op_load <=0;
             op_store <=0;
           
         end
         else begin
         
         if(clear_reserve ==1)begin
         busy <= 0; // if clear reserve is one that means instruction is completed and the station is emptied
         end
         
         else if(issue_en ==1 && busy ==0) begin
         
         op_load <= is_load; //station is not busy and dispatcher needs to issue
         op_store <= is_store;
         imm <= imm_in;
         busy <= 1'b1;   // this means this reservation station is busy, since instruction is happenign
             
             if(rs1_tag == 0)
                 begin
                 V1 <= number_1;
                 tag1 <= 0;
                 end // if number1 is ready then assign to v1
             else
                 begin
                 tag1 <= rs1_tag;//else tag it as busy and store the tag 
                 end
                 
             if(rs2_tag == 0)
                 begin
                 V2 <= number_2;
                 tag2 <= 0;
                 end
             else
                 begin
                 tag2 <= rs2_tag;
                 end
             
         end
         
         else 
         begin
             if((tag1 !=0) && (tag1 == bus_tag)&&bus_en)
             begin
             V1 <= bus_data; // when the data and he tag are broadcasted if it is the required data and the tag matches then assign to that v
              tag1 <= 3'b0; // this means that if the bus information is ok and is ready according 
             end //and that particular tag is sent, so that tag is cleared and then that info is stored
          
             if((tag2 !=0) && (tag2 == bus_tag)&&bus_en)
             begin
             V2 <= bus_data;// same thing with up
             tag2 <= 3'b0;
             end 
         end
         
         end
         
          
      end 
      
      assign address = V1 +imm; // calculating the overall address
      assign writeData = V2; // data to be stored is in V2
      
      assign memRead = ready_for_exec && op_load; // store and load only when all the data is ready
      assign memWrite = ready_for_exec && op_store;// thus it should be ready for execution and the corresponding load or store op
      
      assign out_data = readData;
      
      
        
endmodule

