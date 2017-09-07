module mat_transpose #(parameter M=2, N=3) (
    input [M - 1:0][N - 1:0][31:0] input_mat,
    output [N - 1:0][M - 1:0][31:0] output_mat_transposed
);


genvar i, j;
generate

    for (i = 0; i < M; i = i + 1) begin     :genloop_outer_transpose
        for (j = 0; j < N; j = j + 1) begin     :genloop_inner_transpose
            assign output_mat_transposed[j][i] = input_mat[i][j];
        end
    end

endgenerate

endmodule
