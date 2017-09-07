`timescale 1ns / 1ps

module mat_opposite_tb;

reg [1:0][2:0][31:0] input_mat;
wire [2:0][1:0][31:0] output_mat_opposite;

mat_opposite #(.M(2), .N(3)) dut (
    .input_mat(input_mat),
    .output_mat_opposite(output_mat_opposite)
);
// expected output: {0xBF800000, 0xC0800000, 0xC0000000, 0xC0A00000, 0xC0400000, 0xC0C00000}

initial begin
    $dumpvars();
    input_mat = {32'h3F800000, 32'h40000000, 32'h40400000, 32'h40800000, 32'h40A00000, 32'h40C00000};    // [1, 2, 3; 4, 5, 6]
    #50 $finish;
end

endmodule
