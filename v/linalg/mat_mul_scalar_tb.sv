`timescale 1ns / 1ps

module mat_mul_scalar_tb;

reg clk;
reg rst;
reg [31:0] input_scalar;
reg [1:0][2:0][31:0] input_mat;
reg input_scalar_stb;
reg input_mat_stb;
reg output_mat_ack;
wire [1:0][2:0][31:0] output_mat;
wire input_scalar_ack;
wire input_mat_ack;
wire output_mat_stb;

mat_mul_scalar #(.M(2), .N(3), .N_MULTIPLIERS(4)) uut (.*);

initial begin
    $dumpvars();
    clk = 1'b0;
    rst = 1'b1;
    input_scalar = 32'h40000000;    // 2
    input_mat = {32'h3F800000, 32'h40000000, 32'h40400000, 32'h40800000, 32'h40A00000, 32'h40C00000};    // [1, 2, 3; 4, 5, 6]
    input_scalar_stb = 1'b1;
    input_mat_stb = 1'b1;
    output_mat_ack = 1'b1;
    #10 rst = 0;
    #2000 input_mat = {32'h40C00000, 32'h40A00000, 32'h40800000, 32'h40400000, 32'h40000000, 32'h3F800000}; // [6, 5, 4; 3, 2, 1]
    #2000 input_scalar = 32'hC0000000;  // -2
    #4000 $finish;
end

initial begin
    forever #5 clk = ~clk;
end

endmodule
