module rng #(parameter N=4) (
    input clk,
    input rst,
    input [(1 << (N + 1)) - 1:0] seed,
    output reg [(1 << N) - 1:0] rnd
);

// LFSR pseudo-random number generator of 2^N bits (2 <= N <= 7)
// reference: http://simplefpga.blogspot.com/2013/02/random-number-generator-in-verilog-fpga.html

wire [(1 << N) - 1:0] iv;
wire feedback;

generate
    case (N)
        2: assign feedback = rnd[3] ^ rnd[2];
        3: assign feedback = rnd[7] ^ rnd[5] ^ rnd[4] ^ rnd[3];
        4: assign feedback = rnd[15] ^ rnd[14] ^ rnd[12] ^ rnd[3];
        5: assign feedback = rnd[31] ^ rnd[21] ^ rnd[1] ^ rnd[0];
        6: assign feedback = rnd[63] ^ rnd[62] ^ rnd[60] ^ rnd[59];
        7: assign feedback = rnd[127] ^ rnd[125] ^ rnd[100] ^ rnd[98];
        default: assign feedback = 0;   // invalid
    endcase
endgenerate

assign iv = seed[(1 << (N + 1)) - 1:1 << N] * seed[(1 << N) - 1:0];

always @ (posedge clk) begin

    if (rst) begin
        rnd <= iv;
    end else begin
        rnd <= {rnd[(1 << N) - 2:0], feedback};
    end

end

endmodule
