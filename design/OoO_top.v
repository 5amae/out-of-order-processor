`timescale 1ns / 1ps

module OoO_top(
    input clk,
    input rst
);

   
    wire [31:0] pc_curr, pc_next;
    
    wire [31:0] inst_from_mem;
    
    wire [31:0] queue_inst_out, queue_pc_out;
    wire queue_empty, queue_full;
    
    wire [31:0] rf_readData1, rf_readData2;
    
    wire rat_rs1_busy, rat_rs2_busy;
    wire [2:0] rat_rs1_tag, rat_rs2_tag;
    
    wire [4:0] disp_readReg1, disp_readReg2, disp_rd;
    wire [2:0] disp_rd_tag;
    wire disp_rd_issue_en, disp_deque;
    wire [7:1] disp_rs_issue_en;
    wire [4:0] disp_alu_ctrl;
    wire [31:0] disp_V1, disp_V2;
    wire [2:0] disp_Q1, disp_Q2;
    wire [31:0] disp_imm_val; // Wire for ImmGen
    
    wire [7:1] rs_busy;
    wire [7:1] rs_ready;
    wire [31:0] rs_V1 [1:7], rs_V2 [1:7];
    wire [4:0]  rs_ALUCtrl [1:7];
    
    wire        cdb_en;
    wire [2:0]  cdb_tag;
    wire [31:0] cdb_data;
    
    wire [4:0]  wb_reg;    
    wire        wb_en;     
    
    wire [31:0] alu_A, alu_B, alu_out;
    wire [4:0]  alu_ctrl;
    wire        alu_zero;
    wire        alu_branch_zero;
    
    wire disp_is_load; 
    wire disp_is_store;
    wire memRead;
    wire memWrite;
    wire [31:0] memAddress;
    wire [31:0] memWriteData;
    wire [31:0] memReadData;
    wire [31:0] lsb_out_data;

    reg [4:0] tag_to_rd [1:7];   
    integer k;
    always @(posedge clk or posedge rst) begin
        if (~rst) begin
            for (k=1; k<=7; k=k+1) tag_to_rd[k] <= 5'b0;
        end else if (disp_rd_issue_en && disp_rd_tag != 3'b0) begin
            tag_to_rd[disp_rd_tag] <= disp_rd;
        end
    end
    assign wb_reg = tag_to_rd[cdb_tag];
    assign wb_en  = cdb_en;

   
    assign pc_next = pc_curr + 4; 
    
    PC m_PC (
        .clk(clk),
        .rst(rst),
        .pc_i(pc_next),
        .pc_o(pc_curr)
    );

    assign pc_next = pc_curr + 4;

    InstructionMemory m_InstMem (
        .readAddr(pc_curr),
        .inst(inst_from_mem)
    );

    InstQueue m_Queue (
        .clk(clk),
        .rst(rst),
        .inst(inst_from_mem),
        .pc_i(pc_curr),
        .deque(disp_deque),
        .enque(~queue_full),
        .inst_out(queue_inst_out),
        .pc_o(queue_pc_out),
        .empty(queue_empty),
        .full(queue_full)
    );

    Register m_RegFile (
        .clk(clk),
        .rst(rst),
        .regWrite(wb_en),
        .readReg1(disp_readReg1),
        .readReg2(disp_readReg2),
        .writeReg(wb_reg),
        .writeData(cdb_data),
        .readData1(rf_readData1),
        .readData2(rf_readData2)
    );

    RegAlias m_RAT (
        .clk(clk),
        .rst(rst),
        .rs1(disp_readReg1),
        .rs2(disp_readReg2),
        .rd(disp_rd),
        .rd_tag(disp_rd_tag),
        .issue_en(disp_rd_issue_en),
        .bus_en(cdb_en),
        .bus_tag(cdb_tag),
        .rs1_tag(rat_rs1_tag),
        .rs2_tag(rat_rs2_tag),
        .rs1_busy(rat_rs1_busy),
        .rs2_busy(rat_rs2_busy)
    );

    ImmGen m_ImmGen (
        .inst(queue_inst_out),
        .imm(disp_imm_val)
    );

    Dispatcher m_Dispatcher (
        .inst(queue_inst_out),
        .queue_empty(queue_empty),
        .deque(disp_deque),
        .readData1(rf_readData1),
        .readData2(rf_readData2),
        .imm_val(disp_imm_val), // Pass the immediate value in
        .readReg1(disp_readReg1),
        .readReg2(disp_readReg2),
        .rs1_busy(rat_rs1_busy),
        .rs2_busy(rat_rs2_busy),
        .rs1_tag(rat_rs1_tag),
        .rs2_tag(rat_rs2_tag),
        .rd(disp_rd),
        .rd_issue_en(disp_rd_issue_en),
        .rd_tag(disp_rd_tag),
        .rs_busy_status(rs_busy),
        .rs_issue_en(disp_rs_issue_en),
        .issue_alu_ctrl(disp_alu_ctrl),
        .V1(disp_V1),
        .V2(disp_V2),
        .issue_Q1(disp_Q1),
        .issue_Q2(disp_Q2),
        
        .is_load(disp_is_load),    
        .is_store(disp_is_store)   
   
    );

    ReserveStation RS_1 (
        .clk(clk), 
        .rst(rst),
        .issue_en(disp_rs_issue_en[1]), 
        .ALUCtl(disp_alu_ctrl),
        .number_1(disp_V1), 
        .number_2(disp_V2),
        .rs1_tag(disp_Q1), 
        .rs2_tag(disp_Q2),
        .bus_en(cdb_en), 
        .bus_tag(cdb_tag), 
        .bus_data(cdb_data),
        .clear_reserve(cdb_en && (cdb_tag == 3'd1)),
        .busy(rs_busy[1]), 
        .ready_for_exec(rs_ready[1]),
        .ALU_control(rs_ALUCtrl[1]), 
        .V1(rs_V1[1]), 
        .V2(rs_V2[1])
    );
    
    ReserveStation RS_2 (
        .clk(clk), 
        .rst(rst),
        .issue_en(disp_rs_issue_en[2]), 
        .ALUCtl(disp_alu_ctrl),
        .number_1(disp_V1), 
        .number_2(disp_V2),
        .rs1_tag(disp_Q1), 
        .rs2_tag(disp_Q2),
        .bus_en(cdb_en), 
        .bus_tag(cdb_tag), 
        .bus_data(cdb_data),
        .clear_reserve(cdb_en && (cdb_tag == 3'd2)),
        .busy(rs_busy[2]), 
        .ready_for_exec(rs_ready[2]),
        .ALU_control(rs_ALUCtrl[2]), 
        .V1(rs_V1[2]), 
        .V2(rs_V2[2])
    );
    
    ReserveStation RS_3 (
        .clk(clk), 
        .rst(rst),
        .issue_en(disp_rs_issue_en[3]), 
        .ALUCtl(disp_alu_ctrl),
        .number_1(disp_V1), 
        .number_2(disp_V2),
        .rs1_tag(disp_Q1), 
        .rs2_tag(disp_Q2),
        .bus_en(cdb_en), 
        .bus_tag(cdb_tag), 
        .bus_data(cdb_data),
        .clear_reserve(cdb_en && (cdb_tag == 3'd3)),
        .busy(rs_busy[3]), 
        .ready_for_exec(rs_ready[3]),
        .ALU_control(rs_ALUCtrl[3]), 
        .V1(rs_V1[3]), 
        .V2(rs_V2[3])
    );
    
    ReserveStation RS_4 (
        .clk(clk), 
        .rst(rst),
        .issue_en(disp_rs_issue_en[4]), 
        .ALUCtl(disp_alu_ctrl),
        .number_1(disp_V1), 
        .number_2(disp_V2),
        .rs1_tag(disp_Q1), 
        .rs2_tag(disp_Q2),
        .bus_en(cdb_en), 
        .bus_tag(cdb_tag), 
        .bus_data(cdb_data),
        .clear_reserve(cdb_en && (cdb_tag == 3'd4)),
        .busy(rs_busy[4]), 
        .ready_for_exec(rs_ready[4]),
        .ALU_control(rs_ALUCtrl[4]), 
        .V1(rs_V1[4]), 
        .V2(rs_V2[4])
    );
    
    ReserveStation RS_5 (
        .clk(clk), 
        .rst(rst),
        .issue_en(disp_rs_issue_en[5]), 
        .ALUCtl(disp_alu_ctrl),
        .number_1(disp_V1), 
        .number_2(disp_V2),
        .rs1_tag(disp_Q1), 
        .rs2_tag(disp_Q2),
        .bus_en(cdb_en), 
        .bus_tag(cdb_tag), 
        .bus_data(cdb_data),
        .clear_reserve(cdb_en && (cdb_tag == 3'd5)),
        .busy(rs_busy[5]), 
        .ready_for_exec(rs_ready[5]),
        .ALU_control(rs_ALUCtrl[5]), 
        .V1(rs_V1[5]), 
        .V2(rs_V2[5])
    );
    
    ReserveStation RS_6 (
        .clk(clk), 
        .rst(rst),
        .issue_en(disp_rs_issue_en[6]), 
        .ALUCtl(disp_alu_ctrl),
        .number_1(disp_V1), 
        .number_2(disp_V2),
        .rs1_tag(disp_Q1), 
        .rs2_tag(disp_Q2),
        .bus_en(cdb_en), 
        .bus_tag(cdb_tag), 
        .bus_data(cdb_data),
        .clear_reserve(cdb_en && (cdb_tag == 3'd6)),
        .busy(rs_busy[6]), 
        .ready_for_exec(rs_ready[6]),
        .ALU_control(rs_ALUCtrl[6]), 
        .V1(rs_V1[6]), 
        .V2(rs_V2[6])
    );
    
    LoadStoreBuffer RS_7_loadstore (
        .clk(clk), 
        .rst(rst),
        .issue_en(disp_rs_issue_en[7]),// .ALUCtl(disp_alu_ctrl),
        .is_load(disp_is_load),
        .is_store(disp_is_store),
        .number_1(disp_V1), 
        .number_2(disp_V2),
        .imm_in(disp_imm_val),
        .rs1_tag(disp_Q1), 
        .rs2_tag(disp_Q2),
        .bus_en(cdb_en), 
        .bus_tag(cdb_tag), 
        .bus_data(cdb_data),
        .clear_reserve(cdb_en && (cdb_tag == 3'd7)),
        .memRead(memRead), 
        .memWrite(memWrite),
        .address(memAddress), 
        .writeData(memWriteData),
        .readData(memReadData),
        .busy(rs_busy[7]), 
        .ready_for_exec(rs_ready[7]),
        .out_data(lsb_out_data)
        
    );
    
    DataMemory m_DataMem (
        .clk(clk), 
        .rst(rst),
        .memRead(memRead), 
        .memWrite(memWrite),
        .address(memAddress), 
        .writeData(memWriteData),
        .readData(memReadData)
    );

    assign cdb_tag  = rs_ready[1] ? 3'd1 :
                      rs_ready[2] ? 3'd2 :
                      rs_ready[3] ? 3'd3 :
                      rs_ready[4] ? 3'd4 :
                      rs_ready[5] ? 3'd5 :
                      rs_ready[6] ? 3'd6 :
                      rs_ready[7] ? 3'd7 :
                      3'd0;

    assign cdb_en   = (cdb_tag != 3'd0);
    assign alu_A    = rs_V1[cdb_tag];
    assign alu_B    = rs_V2[cdb_tag];
    assign alu_ctrl = rs_ALUCtrl[cdb_tag];


    ALU m_ALU (
        .ALUCtl(alu_ctrl),
        .A(alu_A),
        .B(alu_B),
        .ALUOut(alu_out),
        .zero(alu_zero),
        .branch_zero(alu_branch_zero)
    );

    assign cdb_data =(cdb_tag == 3'b111) ?lsb_out_data : alu_out; 

endmodule
