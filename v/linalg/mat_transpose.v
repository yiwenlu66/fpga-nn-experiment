module mat_transpose #(parameter M=2, N=3) (
    input [M - 1:0][N - 1:0][31:0] input_a,
    output [N - 1:0][M - 1:0][31:0] output_at
);


genvar i, j;
generate

    for (i = 0; i < M; i = i + 1) begin
        for (j = 0; j < N; j = j + 1) begin
            assign output_at[j][i] = input_a[i][j];
        end
    end

endgenerate

endmodule
