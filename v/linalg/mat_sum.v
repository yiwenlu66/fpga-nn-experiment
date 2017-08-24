module mat_sum #(parameter M=4, N=4) (
    input clk,
    input rst,
    input [M - 1:0][N - 1:0][31:0] input_a, input_b,
    input input_a_stb, input_b_stb,
    input output_z_ack,
    output input_a_ack, input_b_ack,
    output [M - 1:0][N - 1:0][31:0] output_z,
    output output_z_stb
);


wire [M - 1:0][N - 1:0] input_a_units_ack, input_b_units_ack, output_z_units_stb;

genvar i, j;
generate

    for (i = 0; i < M; i = i + 1) begin
        for (j = 0; j < N; j = j + 1) begin
            adder elem (
                .clk(clk),
                .rst(rst),
                .input_a(input_a[i][j]),
                .input_b(input_b[i][j]),
                .input_a_stb(input_a_stb),
                .input_b_stb(input_b_stb),
                .output_z_ack(output_z_ack),
                .input_a_ack(input_a_units_ack[i][j]),
                .input_b_ack(input_b_units_ack[i][j]),
                .output_z(output_z[i][j]),
                .output_z_stb(output_z_units_stb[i][j])
            );
        end
    end

    assign input_a_ack = &input_a_units_ack;
    assign input_b_ack = &input_b_units_ack;
    assign output_z_stb = &output_z_units_stb;

endgenerate

endmodule
