`timescale 1ns / 1ps

module inner_product_tb;

reg [3:0][31:0] a, b;
reg clk, rst;
wire [3:0][31:0] products;   // 4 products corresponding to 4 DUTs
wire [3:0] input_a_ack, input_b_ack, output_z_stb;  // corresponding to 4 DUTs

inner_product #(.N(1)) dut1 (
    .clk(clk),
    .rst(rst),
    .input_a(a[3]),
    .input_b(b[3]),
    .input_a_stb(1'b1),
    .input_b_stb(1'b1),
    .output_z_ack(1'b0),
    .input_a_ack(input_a_ack[0]),
    .input_b_ack(input_b_ack[0]),
    .output_z(products[0]),
    .output_z_stb(output_z_stb[0])
);
// expected output: 0x40A00000 (5)

inner_product #(.N(2)) dut2 (
    .clk(clk),
    .rst(rst),
    .input_a(a[3:2]),
    .input_b(b[3:2]),
    .input_a_stb(1'b1),
    .input_b_stb(1'b1),
    .output_z_ack(1'b0),
    .input_a_ack(input_a_ack[1]),
    .input_b_ack(input_b_ack[1]),
    .output_z(products[1]),
    .output_z_stb(output_z_stb[1])
);
// expected output: 0x41880000 (17)

inner_product #(.N(3)) dut3 (
    .clk(clk),
    .rst(rst),
    .input_a(a[3:1]),
    .input_b(b[3:1]),
    .input_a_stb(1'b1),
    .input_b_stb(1'b1),
    .output_z_ack(1'b0),
    .input_a_ack(input_a_ack[2]),
    .input_b_ack(input_b_ack[2]),
    .output_z(products[2]),
    .output_z_stb(output_z_stb[2])
);
// expected output: 0x42180000 (38)

inner_product #(.N(4)) dut4 (
    .clk(clk),
    .rst(rst),
    .input_a(a),
    .input_b(b),
    .input_a_stb(1'b1),
    .input_b_stb(1'b1),
    .output_z_ack(1'b0),
    .input_a_ack(input_a_ack[3]),
    .input_b_ack(input_b_ack[3]),
    .output_z(products[3]),
    .output_z_stb(output_z_stb[3])
);
// expected output: 0x428C0000 (70)

initial begin
    $dumpvars();
    clk = 0;
    rst = 1;
    a = {32'h3F800000, 32'h40000000, 32'h40400000, 32'h40800000};    // [1, 2, 3, 4]
    b = {32'h40A00000, 32'h40C00000, 32'h40E00000, 32'h41000000};    // [5, 6, 7, 8]
    #10 rst = 0;
end

initial begin
    forever #5 clk = ~clk;
end

always @(posedge clk) begin
    if (&output_z_stb) begin
        #50 $finish;
    end
end

endmodule
