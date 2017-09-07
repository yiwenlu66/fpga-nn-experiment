`timescale 1ns / 1ps

module inner_product_tb;

reg clk, rst;
reg [3:0][31:0] input_v1, input_v2;
reg [5:0] input_v1_stb, input_v2_stb;
reg [5:0] output_prod_ack;
wire [5:0][31:0] output_prod;
wire [5:0] input_v1_ack, input_v2_ack, output_prod_stb;

inner_product #(.N(1), .N_THRESH(1)) uut1 (
    .clk(clk),
    .rst(rst),
    .input_v1(input_v1[3]),
    .input_v2(input_v2[3]),
    .input_v1_stb(input_v1_stb[0]),
    .input_v2_stb(input_v2_stb[0]),
    .output_prod_ack(output_prod_ack[0]),
    .output_prod(output_prod[0]),
    .input_v1_ack(input_v1_ack[0]),
    .input_v2_ack(input_v2_ack[0]),
    .output_prod_stb(output_prod_stb[0])
);
// expected output: 0x40A00000 (5) --> 0x41600000 (14)

inner_product #(.N(2), .N_THRESH(1)) uut2 (
    .clk(clk),
    .rst(rst),
    .input_v1(input_v1[3:2]),
    .input_v2(input_v2[3:2]),
    .input_v1_stb(input_v1_stb[1]),
    .input_v2_stb(input_v2_stb[1]),
    .output_prod_ack(output_prod_ack[1]),
    .output_prod(output_prod[1]),
    .input_v1_ack(input_v1_ack[1]),
    .input_v2_ack(input_v2_ack[1]),
    .output_prod_stb(output_prod_stb[1])
);
// expected output: 0x41880000 (17) --> 0x42180000 (38)

inner_product #(.N(3), .N_THRESH(1)) uut3 (
    .clk(clk),
    .rst(rst),
    .input_v1(input_v1[3:1]),
    .input_v2(input_v2[3:1]),
    .input_v1_stb(input_v1_stb[2]),
    .input_v2_stb(input_v2_stb[2]),
    .output_prod_ack(output_prod_ack[2]),
    .output_prod(output_prod[2]),
    .input_v1_ack(input_v1_ack[2]),
    .input_v2_ack(input_v2_ack[2]),
    .output_prod_stb(output_prod_stb[2])
);
// expected output: 0x42180000 (38) --> 0x42680000 (58)

inner_product #(.N(4), .N_THRESH(1)) uut4_fast (
    .clk(clk),
    .rst(rst),
    .input_v1(input_v1[3:0]),
    .input_v2(input_v2[3:0]),
    .input_v1_stb(input_v1_stb[3]),
    .input_v2_stb(input_v2_stb[3]),
    .output_prod_ack(output_prod_ack[3]),
    .output_prod(output_prod[3]),
    .input_v1_ack(input_v1_ack[3]),
    .input_v2_ack(input_v2_ack[3]),
    .output_prod_stb(output_prod_stb[3])
);
// expected output: 0x428C0000 (70) --> 0x42800000 (64)

inner_product #(.N(4), .N_THRESH(2)) uut4_mid (
    .clk(clk),
    .rst(rst),
    .input_v1(input_v1[3:0]),
    .input_v2(input_v2[3:0]),
    .input_v1_stb(input_v1_stb[4]),
    .input_v2_stb(input_v2_stb[4]),
    .output_prod_ack(output_prod_ack[4]),
    .output_prod(output_prod[4]),
    .input_v1_ack(input_v1_ack[4]),
    .input_v2_ack(input_v2_ack[4]),
    .output_prod_stb(output_prod_stb[4])
);
// expected output: 0x428C0000 (70) --> 0x42800000 (64)

inner_product #(.N(4), .N_THRESH(4)) uut4_slow (
    .clk(clk),
    .rst(rst),
    .input_v1(input_v1[3:0]),
    .input_v2(input_v2[3:0]),
    .input_v1_stb(input_v1_stb[5]),
    .input_v2_stb(input_v2_stb[5]),
    .output_prod_ack(output_prod_ack[5]),
    .output_prod(output_prod[5]),
    .input_v1_ack(input_v1_ack[5]),
    .input_v2_ack(input_v2_ack[5]),
    .output_prod_stb(output_prod_stb[5])
);
// expected output: 0x428C0000 (70) --> 0x42800000 (64)


initial begin
    $dumpvars();
    clk = 0;
    rst = 1;
    input_v1 = {32'h3F800000, 32'h40000000, 32'h40400000, 32'h40800000};    // [1, 2, 3, 4]
    input_v2 = {32'h40A00000, 32'h40C00000, 32'h40E00000, 32'h41000000};    // [5, 6, 7, 8]
    input_v1_stb = {6{1'b1}};
    input_v2_stb = {6{1'b1}};
    output_prod_ack = {6{1'b1}};
    #10 rst = 0;
    #2500
    input_v1 = {32'h40000000, 32'h40400000, 32'h40800000, 32'h3F800000};    // [2, 3, 4, 1]
    input_v2 = {32'h40E00000, 32'h41000000, 32'h40A00000, 32'h40C00000};    // [7, 8, 5, 6]
    #2000 $finish;
end

initial begin
    forever #5 clk = ~clk;
end

endmodule
