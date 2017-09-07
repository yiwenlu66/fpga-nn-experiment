module mat_product
    #(parameter M=1,
                N=1,
                P=1,
                N_INNER_PRODUCTS=1,
                IP_N_THRESH=1) (
    input clk,
    input rst,
    input [M - 1:0][N - 1:0][31:0] input_mat_1,
    input [N - 1:0][P - 1:0][31:0] input_mat_2,
    input input_mat_1_stb,
    input input_mat_2_stb,
    input output_mat_ack,
    output reg [M - 1:0][P - 1:0][31:0] output_mat,
    output reg input_mat_1_ack,
    output reg input_mat_2_ack,
    output reg output_mat_stb
);

localparam N_BATCHES = $rtoi($ceil(1.0 * M * P / N_INNER_PRODUCTS));

reg [2:0] state;
localparam GET_MAT_1          = 3'd0,
           GET_MAT_2          = 3'd1,
           INNER_PRODUCT_IN   = 3'd2,
           INNER_PRODUCT_OUT  = 3'd3,
           PUT_MAT            = 3'd4;

reg [$bits(N_BATCHES) - 1:0] current_batch;

reg [(N_BATCHES * N_INNER_PRODUCTS - 1) / P:0][N - 1:0][31:0] mat_1_aligned;
reg [N - 1:0][P - 1:0][31:0] mat_2;
wire [P - 1:0][N - 1:0][31:0] mat_2_transpose;

mat_transpose #(.M(N), .N(P)) t (
    .input_mat(mat_2),
    .output_mat_transposed(mat_2_transpose)
);

reg [N_BATCHES * N_INNER_PRODUCTS - 1:0][31:0] out_mat_aligned;

reg [N_INNER_PRODUCTS - 1:0][N - 1:0][31:0] workers_input_v1;    // rows from matrix 1
reg [N_INNER_PRODUCTS - 1:0][N - 1:0][31:0] workers_input_v2;    // columns from matrix 2
reg [N_INNER_PRODUCTS - 1:0] workers_input_v1_stb;
reg [N_INNER_PRODUCTS - 1:0] workers_input_v2_stb;
reg [N_INNER_PRODUCTS - 1:0] workers_output_prod_ack;
wire [N_INNER_PRODUCTS - 1:0][31:0] workers_output_prod;
wire [N_INNER_PRODUCTS - 1:0] workers_input_v1_ack;
wire [N_INNER_PRODUCTS - 1:0] workers_input_v2_ack;
wire [N_INNER_PRODUCTS - 1:0] workers_output_prod_stb;

reg [N_INNER_PRODUCTS - 1:0] workers_read_a_done;
reg [N_INNER_PRODUCTS - 1:0] workers_read_b_done;
reg [N_INNER_PRODUCTS - 1:0] workers_write_done;


genvar i;

generate

    always @(posedge clk) begin
        if (rst) begin
            input_mat_1_ack <= 1'b0;
            input_mat_2_ack <= 1'b0;
            output_mat_stb <= 1'b0;
            state <= GET_MAT_1;
            current_batch <= {$bits(N_BATCHES){1'b0}};
            mat_1_aligned <= {(((N_BATCHES * N_INNER_PRODUCTS - 1) / P + 1) * N){32'b0}};
            mat_2 <= {(N * P){32'b0}};
            workers_input_v1_stb <= {N_INNER_PRODUCTS{1'b0}};
            workers_input_v2_stb <= {N_INNER_PRODUCTS{1'b0}};
            workers_output_prod_ack <= {N_INNER_PRODUCTS{1'b0}};
            workers_read_a_done <= {N_INNER_PRODUCTS{1'b0}};
            workers_read_b_done <= {N_INNER_PRODUCTS{1'b0}};
            workers_write_done <= {N_INNER_PRODUCTS{1'b0}};
        end else begin

            case (state)

                GET_MAT_1: begin
                    mat_1_aligned <= {(((N_BATCHES * N_INNER_PRODUCTS - 1) / P + 1) * N){32'b0}};
                    input_mat_1_ack <= 1'b1;
                    if (input_mat_1_ack && input_mat_1_stb) begin
                        mat_1_aligned <= input_mat_1;
                        input_mat_1_ack <= 1'b0;
                        state <= GET_MAT_2;
                    end
                end

                GET_MAT_2: begin
                    input_mat_2_ack <= 1'b1;
                    if (input_mat_2_ack && input_mat_2_stb) begin
                        mat_2 <= input_mat_2;
                        input_mat_2_ack <= 1'b0;
                        state <= INNER_PRODUCT_IN;
                    end
                end

                INNER_PRODUCT_IN: begin
                    begin :block_inner_product_in
                        integer i;
                        for (i = 0; i < N_INNER_PRODUCTS; i = i + 1) begin :loop_innerp_product_in
                            workers_input_v1[i] <= mat_1_aligned[((current_batch * N_INNER_PRODUCTS) + i) / P];
                            workers_input_v2[i] <= mat_2_transpose[((current_batch * N_INNER_PRODUCTS) + i) % P];
                            if (!workers_read_a_done[i]) begin
                                workers_input_v1_stb[i] <= 1'b1;
                            end
                            if (!workers_read_b_done[i]) begin
                                workers_input_v2_stb[i] <= 1'b1;
                            end
                            if (workers_input_v1_stb[i] && workers_input_v1_ack[i]) begin
                                workers_read_a_done[i] <= 1'b1;
                                workers_input_v1_stb[i] <= 1'b0;
                            end
                            if (workers_input_v2_stb[i] && workers_input_v2_ack[i]) begin
                                workers_read_b_done[i] <= 1'b1;
                                workers_input_v2_stb[i] <= 1'b0;
                            end
                        end
                    end
                    if ((&workers_read_a_done) && (&workers_read_b_done)) begin
                        workers_read_a_done <= {N_INNER_PRODUCTS{1'b0}};
                        workers_read_b_done <= {N_INNER_PRODUCTS{1'b0}};
                        state <= INNER_PRODUCT_OUT;
                    end
                end

                INNER_PRODUCT_OUT: begin
                    begin :block_inner_product_out
                        integer i;
                        for (i = 0; i < N_INNER_PRODUCTS; i = i + 1) begin :loop_inner_product_out
                            if (!workers_write_done[i]) begin
                                workers_output_prod_ack[i] <= 1'b1;
                            end
                            if (workers_output_prod_stb[i] && workers_output_prod_ack[i]) begin
                                out_mat_aligned[(current_batch * N_INNER_PRODUCTS) + i] <= workers_output_prod[i];
                                workers_write_done[i] <= 1'b1;
                                workers_output_prod_ack[i] <= 1'b0;
                            end
                        end
                    end
                    if (&workers_write_done) begin
                        workers_write_done <= {N_INNER_PRODUCTS{1'b0}};
                        if (current_batch == N_BATCHES - 1) begin
                            current_batch <= {$bits(N_BATCHES){1'b0}};
                            state <= PUT_MAT;
                        end else begin
                            current_batch <= current_batch + 1;
                            state <= INNER_PRODUCT_IN;
                        end
                    end
                end

                PUT_MAT: begin
                    output_mat <= out_mat_aligned;
                    output_mat_stb <= 1'b1;
                    if (output_mat_stb && output_mat_ack) begin
                        output_mat_stb <= 1'b0;
                        state <= GET_MAT_1;
                    end
                end

            endcase

        end
    end

    for (i = 0; i < N_INNER_PRODUCTS; i = i + 1) begin     :genloop_inner_products
        inner_product #(.N(N), .N_THRESH(IP_N_THRESH)) worker (
            .clk(clk),
            .rst(rst),
            .input_v1(workers_input_v1[i]),
            .input_v2(workers_input_v2[i]),
            .input_v1_stb(workers_input_v1_stb[i]),
            .input_v2_stb(workers_input_v2_stb[i]),
            .output_prod_ack(workers_output_prod_ack[i]),
            .output_prod(workers_output_prod[i]),
            .input_v1_ack(workers_input_v1_ack[i]),
            .input_v2_ack(workers_input_v2_ack[i]),
            .output_prod_stb(workers_output_prod_stb[i])
        );
    end

endgenerate

endmodule
