`timescale 1ns / 1ps

module mat_transpose_tb;

reg [1:0][2:0][31:0] a;
wire [2:0][1:0][31:0] at;

mat_transpose #(.M(2), .N(3)) dut (
    .input_a(a),
    .output_at(at)
);
// expected output: {0x3F800000, 0x40800000, 0x40000000, 0x40A00000, 0x40400000, 0x40C00000}

initial begin
    $dumpvars();
    a = {32'h3F800000, 32'h40000000, 32'h40400000, 32'h40800000, 32'h40A00000, 32'h40C00000};    // [1, 2, 3; 4, 5, 6]
    #50 $finish;
end

endmodule
