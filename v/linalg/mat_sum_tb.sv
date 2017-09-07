`timescale 1ns / 1ps

module mat_sum_tb;

reg clk;
reg rst;
reg [1:0][2:0][31:0] input_mat_1, input_mat_2;
reg input_mat_1_stb, input_mat_2_stb;
reg output_mat_ack;
wire [1:0][2:0][31:0] output_mat_slow, output_mat_fast;
wire input_mat_1_ack_slow, input_mat_1_ack_fast;
wire input_mat_2_ack_slow, input_mat_2_ack_fast;
wire output_mat_stb_slow, output_mat_stb_fast;

mat_sum #(.M(2), .N(3), .N_ADDERS(4)) uut_slow (
    .clk(clk),
    .rst(rst),
    .input_mat_1(input_mat_1),
    .input_mat_2(input_mat_2),
    .input_mat_1_stb(input_mat_1_stb),
    .input_mat_2_stb(input_mat_2_stb),
    .output_mat_ack(output_mat_ack),
    .output_mat(output_mat_slow),
    .input_mat_1_ack(input_mat_1_ack_slow),
    .input_mat_2_ack(input_mat_2_ack_slow),
    .output_mat_stb(output_mat_stb_slow)
);

mat_sum #(.M(2), .N(3), .N_ADDERS(8)) uut_fast (
    .clk(clk),
    .rst(rst),
    .input_mat_1(input_mat_1),
    .input_mat_2(input_mat_2),
    .input_mat_1_stb(input_mat_1_stb),
    .input_mat_2_stb(input_mat_2_stb),
    .output_mat_ack(output_mat_ack),
    .output_mat(output_mat_fast),
    .input_mat_1_ack(input_mat_1_ack_fast),
    .input_mat_2_ack(input_mat_2_ack_fast),
    .output_mat_stb(output_mat_stb_fast)
);


initial begin
    $dumpvars();
    clk = 1'b0;
    rst = 1'b1;
    input_mat_1 = {32'h3F800000, 32'h40000000, 32'h40400000, 32'h40800000, 32'h40A00000, 32'h40C00000};    // [1, 2, 3; 4, 5, 6]
    input_mat_2 = {32'h40000000, 32'h40400000, 32'h40800000, 32'h40A00000, 32'h40C00000, 32'h3F800000};    // [2, 3, 4; 5, 6, 1]
    input_mat_1_stb = 1'b1;
    input_mat_2_stb = 1'b1;
    output_mat_ack = 1'b1;
    #10 rst = 0;
    #2000 input_mat_1 = {32'h40400000, 32'h40800000, 32'h40A00000, 32'h40C00000, 32'h3F800000, 32'h40000000};    // [3, 4, 5; 6, 1, 2]
    #2000 input_mat_2 = {32'h40800000, 32'h40A00000, 32'h40C00000, 32'h3F800000, 32'h40000000, 32'h40400000};    // [4, 5, 6; 1, 2, 3]
    #4000 $finish;
end

// expected results:
//  - [3, 5, 7, 9, 11, 7]: 0x40400000, 0x40A00000, 0x40E00000, 0x41100000, 0x41300000, 0x40E00000
//  - [5, 7, 9, 11, 7, 3]: 0x40A00000, 0x40E00000, 0x41100000, 0x41300000, 0x40E00000, 0x40400000
//  - [7, 9, 11, 7, 3, 5]: 0x40E00000, 0x41100000, 0x41300000, 0x40E00000, 0x40400000, 0x40A00000

initial begin
    forever #5 clk = ~clk;
end

endmodule
