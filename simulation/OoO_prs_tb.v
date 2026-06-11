`timescale 1ns / 1ps

module OoO_prs_tb;

reg clk;
reg rst; // Renamed from 'start' to 'rst' to match the OoO_top input

OoO_top uut (
    .clk(clk), 
    .rst(rst)
);

initial
	forever #5 clk = ~clk;

initial begin
    $dumpfile("ooo_tb.vcd");
    $dumpvars(0, uut);

	clk = 0;
	rst = 0;
	#10 rst = 1;
	
    // The instance name of your Register inside OoO_top is m_RegFile
	#1 uut.m_RegFile.regs[2] = 32'd128; // Initialize sp = 0x80

	#3000 $finish;

end

endmodule
