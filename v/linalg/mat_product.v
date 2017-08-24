module mat_product #(parameter M=8, N=8, P=1) (
    input clk,
    input rst,
    input [M - 1:0][N - 1:0][31:0] input_a,
    input [N - 1:0][P - 1:0][31:0] input_b,
    input input_a_stb, input_b_stb,
    input output_z_ack,
    output input_a_ack, input_b_ack,
    output [M - 1:0][P - 1:0][31:0] output_z,
    output output_z_stb
);


wire [M - 1:0][P - 1:0] input_a_units_ack, input_b_units_ack, output_z_units_stb;

genvar i, j, k;
generate


    for (i = 0; i < M; i = i + 1) begin
        for (j = 0; j < P; j = j + 1) begin
            wire [N - 1:0][31:0] tmp;
            for (k = 0; k < N; k = k + 1) begin
                assign tmp[k] = input_b[k][j];
            end
            inner_product #(.N(N)) elem (
                .clk(clk),
                .rst(rst),
                .input_a(input_a[i]),
                .input_b(tmp),
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
