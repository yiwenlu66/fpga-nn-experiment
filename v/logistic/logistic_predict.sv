module logistic_predict #(parameter N=1,
                                    N_CLASSES=10,
                                    MATMUL_N_INNER_PRODUCTS=1,
                                    MATMUL_IP_N_THRESH=1) (
    input clk,
    input rst,
    input [N - 1:0][31:0] input_X,
    input [N - 1:0][N_CLASSES - 1:0][31:0] input_Theta,
    input input_X_stb, input_Theta_stb,
    input output_prediction_ack,
    output reg [$bits(N_CLASSES) - 1:0] output_prediction,
    output reg input_X_ack, input_Theta_ack,
    output reg output_prediction_stb
);

// TODO: support predicting multiple samples at a time

reg [2:0] state;
localparam GET_X        = 3'd0,
           GET_THETA    = 3'd1,
           MATMUL_IN    = 3'd2,
           MATMUL_OUT   = 3'd3,
           ARGMAX_IN    = 3'd4,
           ARGMAX_OUT   = 3'd5,
           PUT_PRED     = 3'd6;

reg [N - 1:0][31:0] X;
reg [N - 1:0][N_CLASSES - 1:0][31:0] Theta;
reg [N_CLASSES - 1:0][31:0] logits;
reg [$bits(N_CLASSES) - 1:0] result;

wire [0:0][N - 1:0][31:0] matmul_input_mat_1;
wire [N - 1:0][N_CLASSES - 1:0][31:0] matmul_input_mat_2;
reg matmul_input_mat_1_stb, matmul_input_mat_2_stb;
reg matmul_output_mat_ack;
wire [0:0][N_CLASSES - 1:0][31:0] matmul_output_mat;
wire matmul_input_mat_1_ack, matmul_input_mat_2_ack, matmul_output_mat_stb;

reg matmul_read_X_done, matmul_read_Theta_done;

assign matmul_input_mat_1 = X;
assign matmul_input_mat_2 = Theta;

wire [N_CLASSES - 1:0][31:0] argmax_input_v;
reg argmax_input_v_stb;
reg argmax_output_i_ack;
wire [$bits(N_CLASSES) - 1:0] argmax_output_i;
wire argmax_input_v_ack, argmax_output_i_stb;

assign argmax_input_v = logits;

always @(posedge clk) begin
    if (rst) begin
        state <= GET_X;
        matmul_input_mat_1_stb <= 1'b0;
        matmul_input_mat_2_stb <= 1'b0;
        matmul_output_mat_ack <= 1'b0;
        matmul_read_X_done <= 1'b0;
        matmul_read_Theta_done <= 1'b0;
        argmax_input_v_stb <= 1'b0;
        argmax_output_i_ack <= 1'b0;
    end else begin

        case (state)

            GET_X: begin
                input_X_ack <= 1'b1;
                if (input_X_ack && input_X_stb) begin
                    X <= input_X;
                    input_X_ack <= 1'b0;
                    state <= GET_THETA;
                end
            end

            GET_THETA: begin
                input_Theta_ack <= 1'b1;
                if (input_Theta_ack && input_Theta_stb) begin
                    Theta <= input_Theta;
                    input_Theta_ack <= 1'b0;
                    state <= MATMUL_IN;
                end
            end

            MATMUL_IN: begin
                if (!matmul_read_X_done) begin
                    matmul_input_mat_1_stb <= 1'b1;
                end
                if (!matmul_read_Theta_done) begin
                    matmul_input_mat_2_stb <= 1'b1;
                end
                if (matmul_input_mat_1_ack && matmul_input_mat_1_stb) begin
                    matmul_read_X_done <= 1'b1;
                    matmul_input_mat_1_stb <= 1'b0;
                end
                if (matmul_input_mat_2_ack && matmul_input_mat_2_stb) begin
                    matmul_read_Theta_done <= 1'b1;
                    matmul_input_mat_2_stb <= 1'b0;
                end
                if (matmul_read_X_done && matmul_read_Theta_done) begin
                    matmul_read_X_done <= 1'b0;
                    matmul_read_Theta_done <= 1'b0;
                    state <= MATMUL_OUT;
                end
            end

            MATMUL_OUT: begin
                matmul_output_mat_ack <= 1'b1;
                if (matmul_output_mat_ack && matmul_output_mat_stb) begin
                    matmul_output_mat_ack <= 1'b0;
                    logits <= matmul_output_mat;
                    state <= ARGMAX_IN;
                end
            end

            ARGMAX_IN: begin
                argmax_input_v_stb <= 1'b1;
                if (argmax_input_v_ack && argmax_input_v_stb) begin
                    argmax_input_v_stb <= 1'b0;
                    state <= ARGMAX_OUT;
                end
            end

            ARGMAX_OUT: begin
                argmax_output_i_ack <= 1'b1;
                if (argmax_output_i_ack && argmax_output_i_stb) begin
                    argmax_output_i_ack <= 1'b0;
                    result <= argmax_output_i;
                    state <= PUT_PRED;
                end
            end

            PUT_PRED: begin
                output_prediction <= result;
                output_prediction_stb <= 1'b1;
                if (output_prediction_stb && output_prediction_ack) begin
                    output_prediction_stb <= 1'b0;
                    state <= GET_X;
                end
            end

        endcase

    end
end

mat_product #(.M(1), .N(N), .P(N_CLASSES),
    .N_INNER_PRODUCTS(MATMUL_N_INNER_PRODUCTS),
    .IP_N_THRESH(MATMUL_IP_N_THRESH)) matmul (
    .clk(clk),
    .rst(rst),
    .input_mat_1(matmul_input_mat_1),
    .input_mat_2(matmul_input_mat_2),
    .input_mat_1_stb(matmul_input_mat_1_stb),
    .input_mat_2_stb(matmul_input_mat_2_stb),
    .output_mat_ack(matmul_output_mat_ack),
    .output_mat(matmul_output_mat),
    .input_mat_1_ack(matmul_input_mat_1_ack),
    .input_mat_2_ack(matmul_input_mat_2_ack),
    .output_mat_stb(matmul_output_mat_stb)
);

argmax #(.N(N_CLASSES)) argmax_inst (
    .clk(clk),
    .rst(rst),
    .input_v(argmax_input_v),
    .input_v_stb(argmax_input_v_stb),
    .output_i_ack(argmax_output_i_ack),
    .output_i(argmax_output_i),
    .input_v_ack(argmax_input_v_ack),
    .output_i_stb(argmax_output_i_stb)
);

endmodule
