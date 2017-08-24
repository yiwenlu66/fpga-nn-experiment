`timescale 1ns / 1ps

module mat_sum_tb;

reg [1:0][2:0][31:0] a, b;
reg clk, rst;
wire [1:0][2:0][31:0] sum;
wire input_a_ack, input_b_ack, output_z_stb;

mat_sum #(.M(2), .N(3)) dut (
    .clk(clk),
    .rst(rst),
    .input_a(a),
    .input_b(b),
    .input_a_stb(1'b1),
    .input_b_stb(1'b1),
    .output_z_ack(1'b0),
    .input_a_ack(input_a_ack),
    .input_b_ack(input_b_ack),
    .output_z(sum),
    .output_z_stb(output_z_stb)
);
// expected output: 0x40E00000 (7) repeated 6 times

initial begin
    $dumpvars();
    clk = 0;
    rst = 1;
    a = {32'h3F800000, 32'h40000000, 32'h40400000, 32'h40800000, 32'h40A00000, 32'h40C00000};    // [1, 2, 3; 4, 5, 6]
    b = {32'h40C00000, 32'h40A00000, 32'h40800000, 32'h40400000, 32'h40000000, 32'h3F800000};    // [6, 5, 4; 3, 2, 1]
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
