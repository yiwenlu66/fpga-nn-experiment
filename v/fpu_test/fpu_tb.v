`timescale 1ns / 1ps

module fpu_tb();

reg clk, rst;
reg [31:0] a, b;
reg input_a_stb, input_b_stb, sum_ack, product_ack;

wire [31:0] sum, product;
wire add_input_a_ack, add_input_b_ack, sum_stb;
wire mul_input_a_ack, mul_input_b_ack, product_stb;

reg add_input_a_acked, add_input_b_acked, mul_input_a_acked, mul_input_b_acked;
wire input_any_ack;
wire input_all_ack;
wire output_all_ack;

initial begin
    $dumpvars;
    clk = 0;
    a = 0;
    b = 0;
    input_a_stb = 0;
    input_b_stb = 0;
    sum_ack = 0;
    product_ack = 0;
    add_input_a_acked = 0;
    add_input_b_acked = 0;
    mul_input_a_acked = 0;
    mul_input_b_acked = 0;
    forever begin
        #5 clk = ~clk;
    end
end

initial begin
    rst = 1;
    #10 rst = 0;
end

adder add(
    .input_a(a),
    .input_b(b),
    .input_a_stb(input_a_stb),
    .input_b_stb(input_b_stb),
    .output_z_ack(sum_ack),
    .clk(clk),
    .rst(rst),
    .output_z(sum),
    .output_z_stb(sum_stb),
    .input_a_ack(add_input_a_ack),
    .input_b_ack(add_input_b_ack)
);  // expected output: 12.34 + 56.78 = 69.12 (0x428A3D71)

multiplier mul(
    .input_a(a),
    .input_b(b),
    .input_a_stb(input_a_stb),
    .input_b_stb(input_b_stb),
    .output_z_ack(product_ack),
    .clk(clk),
    .rst(rst),
    .output_z(product),
    .output_z_stb(product_stb),
    .input_a_ack(mul_input_a_ack),
    .input_b_ack(mul_input_b_ack)
);  // expected output: 12.34 * 56.78 = 700.6652 (0x442F2A93)

assign input_all_acked = add_input_a_acked && add_input_b_acked && mul_input_a_acked && mul_input_b_acked;
assign output_all_ack = sum_ack && product_ack;

always @(posedge clk) begin

    a <= 32'h414570A4;   // 12.34
    b <= 32'h42631EB8;   // 56.78
    input_a_stb <= 1;
    input_b_stb <= 1;

    if (input_all_acked) begin
        a <= 0;
        b <= 0;
        input_a_stb <= 0;
        input_b_stb <= 0;
    end

    if (sum_stb) begin
        sum_ack <= 1;
    end

    if (product_stb) begin
        product_ack <= 1;
    end

    if (output_all_ack) begin
        #50 $finish;
    end

end

always @(posedge add_input_a_ack) begin
    add_input_a_acked <= 1;
end

always @(posedge add_input_b_ack) begin
    add_input_b_acked <= 1;
end

always @(posedge mul_input_a_ack) begin
    mul_input_a_acked <= 1;
end

always @(posedge mul_input_b_ack) begin
    mul_input_b_acked <= 1;
end

endmodule
