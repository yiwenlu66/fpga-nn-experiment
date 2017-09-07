`timescale 1ns / 1ps

module mat_product_tb;

reg clk;
reg rst;
reg [1:0][2:0][31:0] input_mat_1, input_mat_2;
reg input_mat_1_stb, input_mat_2_stb;
reg output_mat_ack;
wire [1:0][1:0][31:0] output_mat;
wire input_mat_1_ack;
wire input_mat_2_ack;
wire output_mat_stb;

mat_product #(.M(2), .N(3), .P(2), .N_INNER_PRODUCTS(3), .IP_N_THRESH(1)) uut (
    .clk(clk),
    .rst(rst),
    .input_mat_1(input_mat_1),
    .input_mat_2(input_mat_2),
    .input_mat_1_stb(input_mat_1_stb),
    .input_mat_2_stb(input_mat_2_stb),
    .output_mat_ack(output_mat_ack),
    .output_mat(output_mat),
    .input_mat_1_ack(input_mat_1_ack),
    .input_mat_2_ack(input_mat_2_ack),
    .output_mat_stb(output_mat_stb)
);


initial begin
    $dumpvars();
    clk = 1'b0;
    rst = 1'b1;
    input_mat_1 = {32'h3F800000, 32'h40000000, 32'h40400000, 32'h40800000, 32'h40A00000, 32'h40C00000};    // [1, 2, 3; 4, 5, 6]
    input_mat_2 = {32'h3F800000, 32'h40000000, 32'h40400000, 32'h40800000, 32'h40A00000, 32'h40C00000};    // [1, 2; 3, 4; 5, 6]
    input_mat_1_stb = 1'b1;
    input_mat_2_stb = 1'b1;
    output_mat_ack = 1'b1;
    #10 rst = 0;
    #5000 input_mat_1 = {32'h40400000, 32'h40800000, 32'h40A00000, 32'h40C00000, 32'h3F800000, 32'h40000000};    // [3, 4, 5; 6, 1, 2]
    #5000 input_mat_2 = {32'h40800000, 32'h40A00000, 32'h40C00000, 32'h3F800000, 32'h40000000, 32'h40400000};    // [4, 5; 6, 1; 2, 3]
    #5000 $finish;
end

// expected results:
//  - [22, 28, 49, 64]: 0x41B00000, 0x41E00000, 0x42440000, 0x42800000
//  - [40, 52, 19, 28]: 0x42200000, 0x42500000, 0x41980000, 0x41E00000
//  - [46, 34, 34, 37]: 0x42380000, 0x42080000, 0x42080000, 0x42140000

initial begin
    forever #5 clk = ~clk;
end

endmodule
