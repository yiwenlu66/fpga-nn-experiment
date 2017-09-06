module mat_mul_scalar
    #(parameter M=1,
                N=1,
                N_MULTIPLIERS=1) (
    input clk,
    input rst,
    input [31:0] input_scalar,
    input [M - 1:0][N - 1:0][31:0] input_mat,
    input input_scalar_stb,
    input input_mat_stb,
    input output_mat_ack,
    output reg [M - 1:0][N - 1:0][31:0] output_mat,
    output reg input_scalar_ack,
    output reg input_mat_ack,
    output reg output_mat_stb
);

localparam N_BATCHES = $rtoi($ceil(1.0 * M * N / N_MULTIPLIERS));

reg [2:0] state;
localparam GET_SCALAR   = 3'd0,
           GET_MAT      = 3'd1,
           MULTIPLY_IN  = 3'd2,
           MULTIPLY_OUT = 3'd3,
           PUT_MAT      = 3'd4;

reg [$bits(N_BATCHES) - 1:0] current_batch;

reg [31:0] scalar;
reg [N_BATCHES * N_MULTIPLIERS - 1:0][31:0] in_mat_aligned, out_mat_aligned;

reg [N_MULTIPLIERS - 1:0][31:0] workers_input_a; // elements of matrix
wire [31:0] workers_input_b;                     // scalar
reg [N_MULTIPLIERS - 1:0] workers_input_a_stb;
reg [N_MULTIPLIERS - 1:0] workers_input_b_stb;
reg [N_MULTIPLIERS - 1:0] workers_output_z_ack;
wire [N_MULTIPLIERS - 1:0][31:0] workers_output_z;
wire [N_MULTIPLIERS - 1:0] workers_input_a_ack;
wire [N_MULTIPLIERS - 1:0] workers_input_b_ack;
wire [N_MULTIPLIERS - 1:0] workers_output_z_stb;

reg [N_MULTIPLIERS - 1:0] workers_read_a_done;
reg [N_MULTIPLIERS - 1:0] workers_read_b_done;
reg [N_MULTIPLIERS - 1:0] workers_write_done;

assign workers_input_b = scalar;

genvar i;

generate

    always @(posedge clk) begin
        if (rst) begin
            input_scalar_ack <= 1'b0;
            input_mat_ack <= 1'b0;
            output_mat_stb <= 1'b0;
            state <= GET_SCALAR;
            current_batch <= {$bits(N_BATCHES){1'b0}};
            in_mat_aligned <= {(N_BATCHES * N_MULTIPLIERS){32'b0}};
            workers_input_a_stb <= {N_MULTIPLIERS{1'b0}};
            workers_input_b_stb <= {N_MULTIPLIERS{1'b0}};
            workers_output_z_ack <= {N_MULTIPLIERS{1'b0}};
            workers_read_a_done <= {N_MULTIPLIERS{1'b0}};
            workers_read_b_done <= {N_MULTIPLIERS{1'b0}};
            workers_write_done <= {N_MULTIPLIERS{1'b0}};
        end else begin

            case (state)

                GET_SCALAR: begin
                    input_scalar_ack <= 1'b1;
                    if (input_scalar_ack && input_scalar_stb) begin
                        scalar <= input_scalar;
                        input_scalar_ack <= 1'b0;
                        state <= GET_MAT;
                    end
                end

                GET_MAT: begin
                    in_mat_aligned <= {(N_BATCHES * N_MULTIPLIERS){32'b0}};
                    input_mat_ack <= 1'b1;
                    if (input_mat_ack && input_mat_stb) begin
                        in_mat_aligned <= input_mat;
                        input_mat_ack <= 1'b0;
                        state <= MULTIPLY_IN;
                    end
                end

                MULTIPLY_IN: begin
                    begin :block_multiply_in
                        integer i;
                        for (i = 0; i < N_MULTIPLIERS; i = i + 1) begin :loop_multiply_in
                            workers_input_a[i] <= in_mat_aligned[(current_batch * N_MULTIPLIERS) + i];
                            if (!workers_read_a_done[i]) begin
                                workers_input_a_stb[i] <= 1'b1;
                            end
                            if (!workers_read_b_done[i]) begin
                                workers_input_b_stb[i] <= 1'b1;
                            end
                            if (workers_input_a_stb[i] && workers_input_a_ack[i]) begin
                                workers_read_a_done[i] <= 1'b1;
                                workers_input_a_stb[i] <= 1'b0;
                            end
                            if (workers_input_b_stb[i] && workers_input_b_ack[i]) begin
                                workers_read_b_done[i] <= 1'b1;
                                workers_input_b_stb[i] <= 1'b0;
                            end
                        end
                    end
                    if ((&workers_read_a_done) && (&workers_read_b_done)) begin
                        workers_read_a_done <= {N_MULTIPLIERS{1'b0}};
                        workers_read_b_done <= {N_MULTIPLIERS{1'b0}};
                        state <= MULTIPLY_OUT;
                    end
                end

                MULTIPLY_OUT: begin
                    begin :block_multiply_out
                        integer i;
                        for (i = 0; i < N_MULTIPLIERS; i = i + 1) begin :loop_multiply_out
                            if (!workers_write_done[i]) begin
                                workers_output_z_ack[i] <= 1'b1;
                            end
                            if (workers_output_z_stb[i] && workers_output_z_ack[i]) begin
                                out_mat_aligned[(current_batch * N_MULTIPLIERS) + i] <= workers_output_z[i];
                                workers_write_done[i] <= 1'b1;
                                workers_output_z_ack[i] <= 1'b0;
                            end
                        end
                    end
                    if (&workers_write_done) begin
                        workers_write_done <= {N_MULTIPLIERS{1'b0}};
                        if (current_batch == N_BATCHES - 1) begin
                            current_batch <= {$bits(N_BATCHES){1'b0}};
                            state <= PUT_MAT;
                        end else begin
                            current_batch <= current_batch + 1;
                            state <= MULTIPLY_IN;
                        end
                    end
                end

                PUT_MAT: begin
                    output_mat <= out_mat_aligned;
                    output_mat_stb <= 1'b1;
                    if (output_mat_stb && output_mat_ack) begin
                        output_mat_stb <= 1'b0;
                        state <= GET_SCALAR;
                    end
                end

            endcase

        end
    end

    for (i = 0; i < N_MULTIPLIERS; i = i + 1) begin     :genloop_multipliers
        multiplier worker (
            .clk(clk),
            .rst(rst),
            .input_a(workers_input_a[i]),
            .input_b(workers_input_b),
            .input_a_stb(workers_input_a_stb[i]),
            .input_b_stb(workers_input_b_stb[i]),
            .output_z_ack(workers_output_z_ack[i]),
            .output_z(workers_output_z[i]),
            .input_a_ack(workers_input_a_ack[i]),
            .input_b_ack(workers_input_b_ack[i]),
            .output_z_stb(workers_output_z_stb[i])
        );
    end

endgenerate

endmodule
