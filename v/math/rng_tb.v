`timescale 1ns / 1ps

module rng_tb;

reg clk, rst;
wire [31:0] rnd;

initial begin
    $dumpvars();
    clk = 0;
    rst = 1;
    #10 rst = 0;
    #500 rst = 1;
    #10 rst = 0;
    #1000 $finish;
end

initial begin
    forever #5 clk = ~clk;
end

rng #(.N(5)) rng (
    .clk(clk),
    .rst(rst),
    .seed(64'h0123456789ABCDEF),
    .rnd(rnd)
);

endmodule
