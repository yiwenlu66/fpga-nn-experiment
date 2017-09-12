module cmp_tb;

reg [31:0] input_x1, input_x2;
wire [1:0] output_result;

initial begin
    $dumpvars;
    input_x1 = 32'h3f800000;    // 1
    input_x2 = 32'hc1200000;    // -10
    #100
    input_x1 = 32'hc0200000;    // -2.5
    input_x2 = 32'hc0000000;    // -2
    #100
    input_x1 = 32'h3f800000;    // 1
    input_x2 = 32'h3f800000;    // 1
    #100 $finish;
end

cmp uut (
    .input_x1(input_x1),
    .input_x2(input_x2),
    .output_result(output_result)
);

endmodule
