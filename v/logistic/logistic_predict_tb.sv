module logistic_predict_tb;

reg clk, rst;
reg [1:0][31:0] input_X;
reg [1:0][2:0][31:0] input_Theta;
reg input_X_stb, input_Theta_stb;
reg output_prediction_ack;
wire [1:0] output_prediction;
wire input_X_ack, input_Theta_ack;
wire output_prediction_stb;

initial begin
    $dumpvars();
    clk = 1'b0;
    rst = 1'b1;
    input_X_stb = 1'b1;
    input_Theta_stb = 1'b1;
    output_prediction_ack = 1'b1;
    #10 rst = 0;
    input_X = {32'h3f800000, 32'h40000000};         // [1, 2]
    input_Theta = {32'h3f800000, 32'h40400000, 32'h40000000,
                   32'h40000000, 32'h40800000, 32'h3f800000};         // [1, 3, 2; 2, 4, 1]
    // expected logits: [5, 11, 4] (0x40a00000, 0x41300000, 0x40800000)
    #10000 $finish;
end

initial begin
    forever #5 clk = ~clk;
end

logistic_predict #(.N(2), .N_CLASSES(3), .MATMUL_N_INNER_PRODUCTS(1), .MATMUL_IP_N_THRESH(1)) uut (
    .clk(clk),
    .rst(rst),
    .input_X(input_X),
    .input_X_stb(input_X_stb),
    .input_Theta(input_Theta),
    .input_Theta_stb(input_Theta_stb),
    .output_prediction_ack(output_prediction_ack),
    .output_prediction(output_prediction),
    .input_X_ack(input_X_ack),
    .input_Theta_ack(input_Theta_ack),
    .output_prediction_stb(output_prediction_stb)
);


endmodule
