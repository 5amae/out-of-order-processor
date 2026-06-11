`timescale 1ns / 1ps
//this is essentially like a queueue which holds 8 instructions and whenever the dispatcher sees the opening in any reservation station 
//that iswhen the queue is not empty and the dispatcher sees an empty reservation station this deque command is applied and the instruction is sent to that 
//reservation station, where it is processed and ended, basically just a queue which is handled by the dispatcher
//
//
module InstQueue(
    input clk, rst,
    input [31:0] inst, // the instruction is given
    input[31:0] pc_i, // the pc input is given from the program counter
    input deque,// remove the latest instruction from the queue
    input enque, // adds and instruction to queue
    output [31:0] inst_out, // that only the latest instruction
    output [31:0] pc_o,// the output PC
    output empty,// the queue is empty
    output full // the queue is absolutely full

    );
    // since we need to make the registers hold 8 total instructions we will make 8 registers
    reg [31:0] queue[0:7];  // holds inst
    reg [31:0] pc_queue[0:7]; // holds the pc_i
    
    reg [2:0] head;// points to the head of the queueu from where the instruction is taken
    reg [2:0] tail;// points to the tail of the queue 
    
    reg [3:0] count; // how many instructions are currently in the queue

    assign empty = (count == 4'b0000) ? 1 : 0; // if count is 0 then the queue is empty
    assign full = (count == 4'b1000) ? 1 : 0; // if count is 8 then the queue is full
    assign inst_out = queue[head]; // the instruction assigned to the instruction out will be the first instruction added, or the earliest instruction
    assign pc_o = pc_queue[head]; // the pc of the corresopnding instruction will be the earliest pc recieved by the insqueueu
    
    integer i;
    
    always@( posedge clk or posedge rst)
    begin
    if(~rst)
           begin
    
                head <= 3'b000; // if it is resetted then all the values of head tail and count will be reset to 0
                tail <= 3'b000;
                count <= 3'b000;
   
                for(i=0; i<8 ;i=i+1)
                begin
                    queue[i] <= 32'b0;
                    pc_queue[i] <= 32'b0; // loop for assigning 0 to all the pc and inst registers in the queueu
                end

           end
    
    else 
    
    if(enque == 1 && full == 0 && deque ==1 && empty ==0)
        begin
            queue[tail] <= inst; // pc_oout and all are assigned outside the always @ block in line 23-26
            pc_queue[tail] <= pc_i; // the new insturction and the new pc are added to the end of the queue
            tail <= tail +1; //tail shifts forward like if tail was at 4 it goes to 5 , since a new instruction was added
            head <= head +1; // head shifts forward since an instruction was dequeed
        // count is the same since one is enqued and one is dequed
        
        end
    
    else if(enque == 1 && full == 0 && deque ==0)
        begin
            queue[tail] <= inst; // only enqueue so the tail is incremented
            pc_queue[tail] <= pc_i; // input signals are added to the registers
            tail <= tail +1;
            count <= count +1; // since an instruction is added the count increases by one
        end
        
    else if(enque == 0 && deque ==1 && empty == 0)
        begin
            head <= head +1; // head is incremented and all the assign statements for the pc_o and inst_out are given in line 25 and 26
            count <= count - 1; // only these two are changed since the assign statements take care
        
        end
    end
endmodule


