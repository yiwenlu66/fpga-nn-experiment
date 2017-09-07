module mat_sigmoid
    #(parameter M=1,
                N=1,
                N_SIGMOID=1) (
    input clk,
    input rst,
    input [M - 1:0][N - 1:0][31:0] input_mat,
    input input_mat_stb,
    input output_mat_ack,
    output reg [M - 1:0][N - 1:0][31:0] output_mat,
    output reg input_mat_ack,
    output reg output_mat_stb
);

localparam N_BATCHES = $rtoi($ceil(1.0 * M * N / N_SIGMOID));

reg [1:0] state;
localparam GET_MAT     = 2'd0,
           SIGMOID_IN  = 2'd1,
           SIGMOID_OUT = 2'd2,
           PUT_MAT     = 2'd3;

reg [$bits(N_BATCHES) - 1:0] current_batch;

reg [N_BATCHES * N_SIGMOID - 1:0][31:0] in_mat_aligned, out_mat_aligned;

reg [N_SIGMOID - 1:0][31:0] workers_input_x;
reg [N_SIGMOID - 1:0] workers_input_x_stb;
reg [N_SIGMOID - 1:0] workers_output_s_ack;
wire [N_SIGMOID - 1:0][31:0] workers_output_s;
wire [N_SIGMOID - 1:0] workers_input_x_ack;
wire [N_SIGMOID - 1:0] workers_output_s_stb;

reg [N_SIGMOID - 1:0] workers_read_done;
reg [N_SIGMOID - 1:0] workers_write_done;

genvar i;

generate

    always @(posedge clk) begin
        if (rst) begin
            input_mat_ack <= 1'b0;
            output_mat_stb <= 1'b0;
            state <= GET_MAT;
            current_batch <= {$bits(N_BATCHES){1'b0}};
            in_mat_aligned <= {(N_BATCHES * N_SIGMOID){32'b0}};
            workers_input_x_stb <= {N_SIGMOID{1'b0}};
            workers_output_s_ack <= {N_SIGMOID{1'b0}};
            workers_read_done <= {N_SIGMOID{1'b0}};
            workers_write_done <= {N_SIGMOID{1'b0}};
        end else begin

            case (state)

                GET_MAT: begin
                    in_mat_aligned <= {(N_BATCHES * N_SIGMOID){32'b0}};
                    input_mat_ack <= 1'b1;
                    if (input_mat_ack && input_mat_stb) begin
                        in_mat_aligned <= input_mat;
                        input_mat_ack <= 1'b0;
                        state <= SIGMOID_IN;
                    end
                end

                SIGMOID_IN: begin
                    begin :block_sigmoid_in
                        integer i;
                        for (i = 0; i < N_SIGMOID; i = i + 1) begin :loop_sigmoid_in
                            workers_input_x[i] <= in_mat_aligned[(current_batch * N_SIGMOID) + i];
                            if (!workers_read_done[i]) begin
                                workers_input_x_stb[i] <= 1'b1;
                            end
                            if (workers_input_x_stb[i] && workers_input_x_ack[i]) begin
                                workers_read_done[i] <= 1'b1;
                                workers_input_x_stb[i] <= 1'b0;
                            end
                        end
                    end
                    if (&workers_read_done) begin
                        workers_read_done <= {N_SIGMOID{1'b0}};
                        state <= SIGMOID_OUT;
                    end
                end

                SIGMOID_OUT: begin
                    begin :block_sigmoid_out
                        integer i;
                        for (i = 0; i < N_SIGMOID; i = i + 1) begin :loop_sigmoid_out
                            if (!workers_write_done[i]) begin
                                workers_output_s_ack[i] <= 1'b1;
                            end
                            if (workers_output_s_stb[i] && workers_output_s_ack[i]) begin
                                out_mat_aligned[(current_batch * N_SIGMOID) + i] <= workers_output_s[i];
                                workers_write_done[i] <= 1'b1;
                                workers_output_s_ack[i] <= 1'b0;
                            end
                        end
                    end
                    if (&workers_write_done) begin
                        workers_write_done <= {N_SIGMOID{1'b0}};
                        if (current_batch == N_BATCHES - 1) begin
                            current_batch <= {$bits(N_BATCHES){1'b0}};
                            state <= PUT_MAT;
                        end else begin
                            current_batch <= current_batch + 1;
                            state <= SIGMOID_IN;
                        end
                    end
                end

                PUT_MAT: begin
                    output_mat <= out_mat_aligned;
                    output_mat_stb <= 1'b1;
                    if (output_mat_stb && output_mat_ack) begin
                        output_mat_stb <= 1'b0;
                        state <= GET_MAT;
                    end
                end

            endcase

        end
    end

    for (i = 0; i < N_SIGMOID; i = i + 1) begin     :genloop_sigmoid_units
        sigmoid worker (
            .clk(clk),
            .rst(rst),
            .input_x(workers_input_x[i]),
            .input_x_stb(workers_input_x_stb[i]),
            .output_s_ack(workers_output_s_ack[i]),
            .output_s(workers_output_s[i]),
            .input_x_ack(workers_input_x_ack[i]),
            .output_s_stb(workers_output_s_stb[i])
        );
    end

endgenerate

endmodule
