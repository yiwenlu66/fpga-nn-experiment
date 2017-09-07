module sigmoid_tb;

reg clk, rst;
reg [31:0] input_x;
reg input_x_stb;
reg output_s_ack;
wire [31:0] output_s;
wire input_x_ack;
wire output_s_stb;

initial begin
    $dumpvars();
    clk = 1'b0;
    rst = 1'b1;
    input_x_stb = 1'b1;
    output_s_ack = 1'b1;
    #10 rst = 0;
    input_x = 32'hc0c00000;         // -6
    #1000 input_x = 32'hc0800000;    // -4
    #1000 input_x = 32'hc0000000;    // -2
    #1000 input_x = 32'hbf800000;    // -1
    #1000 input_x = 32'h0;           // -0
    #1000 input_x = 32'h3f800000;    // 1
    #1000 input_x = 32'h40000000;    // 2
    #1000 input_x = 32'h40800000;    // 4
    #1000 input_x = 32'h40c00000;    // 6
    #1000 $finish;
end

// expected output: [0, 0.03125, 0.125, 0.25, 0.5, 0.75, 0.875, 0.96875, 1]
// 0x00000000, 0x3d000000, 0x3e000000, 0x3e800000, 0x3f000000, 0x3f400000,
// 0x3f600000, 0x3f780000, 0x3f800000

initial begin
    forever #5 clk = ~clk;
end

sigmoid uut (
    .clk(clk),
    .rst(rst),
    .input_x(input_x),
    .input_x_stb(input_x_stb),
    .output_s_ack(output_s_ack),
    .output_s(output_s),
    .input_x_ack(input_x_ack),
    .output_s_stb(output_s_stb)
);

endmodule
