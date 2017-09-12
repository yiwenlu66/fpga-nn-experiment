module argmax_tb;

reg clk, rst;
reg [2:0][31:0] input_v;
reg input_v_stb;
reg output_i_ack;
wire [1:0] output_i;
wire input_v_ack;
wire output_i_stb;

initial begin
    $dumpvars();
    clk = 1'b0;
    rst = 1'b1;
    input_v_stb = 1'b1;
    output_i_ack = 1'b1;
    #10 rst = 0;
    input_v = {32'h3f800000, 32'h40000000, 32'h40400000};         // [1, 2, 3]
    #1000
    input_v = {32'h40000000, 32'h40400000, 32'h3f800000};         // [2, 3, 1]
    #1000 $finish;
end

initial begin
    forever #5 clk = ~clk;
end

argmax #(.N(3)) uut (
    .clk(clk),
    .rst(rst),
    .input_v(input_v),
    .input_v_stb(input_v_stb),
    .output_i_ack(output_i_ack),
    .output_i(output_i),
    .input_v_ack(input_v_ack),
    .output_i_stb(output_i_stb)
);

endmodule
