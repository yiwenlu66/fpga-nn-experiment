`timescale 1ns / 1ps

module mat_sigmoid_tb;

reg clk;
reg rst;
reg [1:0][2:0][31:0] input_mat;
reg input_mat_stb;
reg output_mat_ack;
wire [1:0][2:0][31:0] output_mat;
wire input_mat_ack;
wire output_mat_stb;

mat_sigmoid #(.M(2), .N(3), .N_SIGMOID(4)) uut (
    .clk(clk),
    .rst(rst),
    .input_mat(input_mat),
    .input_mat_stb(input_mat_stb),
    .output_mat_ack(output_mat_ack),
    .output_mat(output_mat),
    .input_mat_ack(input_mat_ack),
    .output_mat_stb(output_mat_stb)
);

initial begin
    $dumpvars();
    clk = 1'b0;
    rst = 1'b1;
    input_mat = {32'h3dcccccc, 32'h3e4ccccc, 32'h3e999999, 32'h3ecccccc, 32'h3f000000, 32'h3f199999};    // [0.1, 0.2, 0.3; 0.4, 0.5, 0.6]
    input_mat_stb = 1'b1;
    output_mat_ack = 1'b1;
    #10 rst = 0;
    #2000 input_mat = {32'h3f199999, 32'h3f000000, 32'h3ecccccc, 32'h3e999999, 32'h3e4ccccc, 32'h3dcccccc}; // [0.6, 0.5, 0.4; 0.3, 0.2, 0.1]
    #2000 $finish;
end
// 0.5250     0.5500     0.5750     0.6000     0.6250     0.6500
// 0x3f066666 0x3f0ccccc 0x3f133333 0x3f199999 0x3f200000 0x3f266666

initial begin
    forever #5 clk = ~clk;
end

endmodule
