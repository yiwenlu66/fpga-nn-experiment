module mat_opposite #(parameter M=1, N=1) (
    input [M - 1:0][N - 1:0][31:0] input_mat,
    output [N - 1:0][M - 1:0][31:0] output_mat_opposite
);


genvar i, j;
generate

    for (i = 0; i < M; i = i + 1) begin     :genloop_outer_opposite
        for (j = 0; j < N; j = j + 1) begin     :genloop_inner_opposite
            assign output_mat_opposite[j][i] = {~input_mat[i][j][31], input_mat[i][j][30:0]};
        end
    end

endgenerate

endmodule
