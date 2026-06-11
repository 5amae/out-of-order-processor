# out-of-order-processor
this is a basic out of order processor consisting of R I L S type instructions

# RISC-V Out-of-Order (OoO) Processor utilizing Tomasulo's Algorithm

A high-performance, synthesizable Out-of-Order (OoO) Execution RISC-V Core implemented in Verilog. This processor implements Tomasulo's Algorithm to handle dynamic instruction scheduling, register renaming, and execution hazard resolution, featuring an integrated Out-of-Order Memory Subsystem via a Load-Store Buffer (LSB).

- Dynamic Scheduling (Tomasulo's Algorithm): Minimizes RAW/WAW/WAR hazards and maximizes instruction-level parallelism (ILP) by executing instructions as soon as operands are ready, rather than in strict program order.
- Register Renaming: Implemented via a Register Alias Table (RAT) with a 32-bit busy/tag tracking system to eliminate WAR and WAW hazards.
- Unified Common Data Bus (CDB): Broadcasts execution results, tags, and valid flags to all Reservation Stations, the RAT, and the Load-Store Buffer concurrently in a single clock cycle.
- Memory Disambiguation: A dedicated Load-Store Buffer (LSB) handles execution of memory operations (LW, SW) out-of-order, maintaining data integrity during memory hazards.
- Modular Design: Fully decoupled Fetch (PC/Queue), Decode/Dispatch, Execute (Reservation Stations/ALU), Memory (LSB/Data Memory), and Writeback stages.

    PC[Program Counter] --> IM[Instruction Memory]
    IM --> IQ[Instruction Queue]
    IQ --> DISP[Dispatcher]
    
    DISP --> RAT[Register Alias Table / RAT]
    RAT --> DISP
    
    DISP --> RS[Reservation Stations - Math]
    DISP --> LSB[Load-Store Buffer]
    
    RS --> ALU[ALU Exec Unit]
    LSB --> DM[Data Memory]
    
    ALU --> CDB[Common Data Bus / CDB]
    DM --> CDB
    
    CDB -.-> RAT
    CDB -.-> RS
    CDB -.-> LSB
