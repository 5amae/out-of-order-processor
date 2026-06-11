module ImmGen#(parameter Width = 32) (
    input [Width-1:0] inst,
    output reg signed [Width-1:0] imm
);
    // ImmGen generate imm value based on opcode
    // based on opcode, every code is dissected into diffrent sections with diffrent immediate value distribution within the 32 bits
    //all these values are merged together and sign exteneded for arithmetic and branch requiremnets

    wire [6:0] opcode = inst[6:0];
    always @(*) 
    begin
        case(opcode)
            7'b0010011: //addi subi ori slti andi lw all I type instructions
            begin
                if(inst[14:12] == 3'b101 || inst[14:12] == 3'b001)
                    begin
                    imm = {{20{1'b0}},inst[24:20]};
                    end
                else if(inst[14:12] == 3'b011)
                    begin
                    imm = $unsigned({{20{inst[31]}},inst[31:20]});
                    end
                else
                    begin
                    imm = {{20{inst[31]}},inst[31:20]};
                    end
            end


            7'b1100011: //beq bneq bgt all these instruction are included all branch type instruction are having the same bit distribution in rv32i
            begin
                //imm[12] = inst[31];
                //imm[11] = inst[7];
                //imm[10:5] = inst[30:25];
                //imm[4:1] = inst[11:8] 
                imm = {1'b0,{20{inst[31]}}, inst[7], inst[30:25], inst[11:8]};
 
            end
            7'b0000011://lw
            begin
                imm = {{20{inst[31]}},inst[31:20]};
            end


            7'b0100011://sw
            begin
                //imm[11:5] = inst[31:25];
                  //imm[4:0] =inst[11:7];
                imm = {{20{inst[31]}},inst[31:25],inst[11:7]};
            end


            7'b1101111://jal
            begin
                //imm[20] = inst[31];
                //imm[19:12] = inst[19:11];
                 //imm[11] = inst[20];
                //imm[10:1] = inst[30:21];
                imm ={1'b0,{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21]};
            end
            

	endcase
    end
            
endmodule

