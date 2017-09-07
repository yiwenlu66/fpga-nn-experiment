module mat_sum
    #(parameter M=1,
                N=1,
                N_ADDERS=1) (
    input clk,
    input rst,
    input [M - 1:0][N - 1:0][31:0] input_mat_1,
    input [M - 1:0][N - 1:0][31:0] input_mat_2,
    input input_mat_1_stb,
    input input_mat_2_stb,
    input output_mat_ack,
    output reg [M - 1:0][N - 1:0][31:0] output_mat,
    output reg input_mat_1_ack,
    output reg input_mat_2_ack,
    output reg output_mat_stb
);

localparam N_BATCHES = $rtoi($ceil(1.0 * M * N / N_ADDERS));

reg [2:0] state;
localparam GET_MAT_1    = 3'd0,
           GET_MAT_2    = 3'd1,
           ADD_IN       = 3'd2,
           ADD_OUT      = 3'd3,
           PUT_MAT      = 3'd4;

reg [$bits(N_BATCHES) - 1:0] current_batch;

reg [N_BATCHES * N_ADDERS - 1:0][31:0] in_mat_1_aligned, in_mat_2_aligned, out_mat_aligned;

reg [N_ADDERS - 1:0][31:0] workers_input_a;    // elements from matrix 1
reg [N_ADDERS - 1:0][31:0] workers_input_b;    // elements from matrix 2
reg [N_ADDERS - 1:0] workers_input_a_stb;
reg [N_ADDERS - 1:0] workers_input_b_stb;
reg [N_ADDERS - 1:0] workers_output_z_ack;
wire [N_ADDERS - 1:0][31:0] workers_output_z;
wire [N_ADDERS - 1:0] workers_input_a_ack;
wire [N_ADDERS - 1:0] workers_input_b_ack;
wire [N_ADDERS - 1:0] workers_output_z_stb;

reg [N_ADDERS - 1:0] workers_read_a_done;
reg [N_ADDERS - 1:0] workers_read_b_done;
reg [N_ADDERS - 1:0] workers_write_done;


genvar i;

generate

    always @(posedge clk) begin
        if (rst) begin
            input_mat_1_ack <= 1'b0;
            input_mat_2_ack <= 1'b0;
            output_mat_stb <= 1'b0;
            state <= GET_MAT_1;
            current_batch <= {$bits(N_BATCHES){1'b0}};
            in_mat_1_aligned <= {(N_BATCHES * N_ADDERS){32'b0}};
            in_mat_2_aligned <= {(N_BATCHES * N_ADDERS){32'b0}};
            workers_input_a_stb <= {N_ADDERS{1'b0}};
            workers_input_b_stb <= {N_ADDERS{1'b0}};
            workers_output_z_ack <= {N_ADDERS{1'b0}};
            workers_read_a_done <= {N_ADDERS{1'b0}};
            workers_read_b_done <= {N_ADDERS{1'b0}};
            workers_write_done <= {N_ADDERS{1'b0}};
        end else begin

            case (state)

                GET_MAT_1: begin
                    in_mat_1_aligned <= {(N_BATCHES * N_ADDERS){32'b0}};
                    input_mat_1_ack <= 1'b1;
                    if (input_mat_1_ack && input_mat_1_stb) begin
                        in_mat_1_aligned <= input_mat_1;
                        input_mat_1_ack <= 1'b0;
                        state <= GET_MAT_2;
                    end
                end

                GET_MAT_2: begin
                    in_mat_2_aligned <= {(N_BATCHES * N_ADDERS){32'b0}};
                    input_mat_2_ack <= 1'b1;
                    if (input_mat_2_ack && input_mat_2_stb) begin
                        in_mat_2_aligned <= input_mat_2;
                        input_mat_2_ack <= 1'b0;
                        state <= ADD_IN;
                    end
                end

                ADD_IN: begin
                    begin :block_add_in
                        integer i;
                        for (i = 0; i < N_ADDERS; i = i + 1) begin :loop_add_in
                            workers_input_a[i] <= in_mat_1_aligned[(current_batch * N_ADDERS) + i];
                            workers_input_b[i] <= in_mat_2_aligned[(current_batch * N_ADDERS) + i];
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
                        workers_read_a_done <= {N_ADDERS{1'b0}};
                        workers_read_b_done <= {N_ADDERS{1'b0}};
                        state <= ADD_OUT;
                    end
                end

                ADD_OUT: begin
                    begin :block_add_out
                        integer i;
                        for (i = 0; i < N_ADDERS; i = i + 1) begin :loop_add_out
                            if (!workers_write_done[i]) begin
                                workers_output_z_ack[i] <= 1'b1;
                            end
                            if (workers_output_z_stb[i] && workers_output_z_ack[i]) begin
                                out_mat_aligned[(current_batch * N_ADDERS) + i] <= workers_output_z[i];
                                workers_write_done[i] <= 1'b1;
                                workers_output_z_ack[i] <= 1'b0;
                            end
                        end
                    end
                    if (&workers_write_done) begin
                        workers_write_done <= {N_ADDERS{1'b0}};
                        if (current_batch == N_BATCHES - 1) begin
                            current_batch <= {$bits(N_BATCHES){1'b0}};
                            state <= PUT_MAT;
                        end else begin
                            current_batch <= current_batch + 1;
                            state <= ADD_IN;
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

    for (i = 0; i < N_ADDERS; i = i + 1) begin     :genloop_adders
        adder worker (
            .clk(clk),
            .rst(rst),
            .input_a(workers_input_a[i]),
            .input_b(workers_input_b[i]),
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
