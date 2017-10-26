
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module fpga_dl(

	//////////// CLOCK //////////
	CLOCK_50,
	CLOCK2_50,
	CLOCK3_50,

	//////////// LED //////////
	LEDG,
	LEDR,

	//////////// SEG7 //////////
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	HEX6,
	HEX7 
);

//=======================================================
//  PARAMETER declarations
//=======================================================


//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input 		          		CLOCK_50;
input 		          		CLOCK2_50;
input 		          		CLOCK3_50;

//////////// LED //////////
output		     [8:0]		LEDG;
output		    [17:0]		LEDR;

//////////// SEG7 //////////
output		     [6:0]		HEX0;
output		     [6:0]		HEX1;
output		     [6:0]		HEX2;
output		     [6:0]		HEX3;
output		     [6:0]		HEX4;
output		     [6:0]		HEX5;
output		     [6:0]		HEX6;
output		     [6:0]		HEX7;


//=======================================================
//  REG/WIRE declarations
//=======================================================

localparam N = 15;
localparam N_CLASSES = 10;

reg [7:0] addr;
reg [31:0] read_data;

reg [N - 1:0][31:0] X;
reg [N - 1:0][N_CLASSES - 1:0][31:0] Theta;
reg [$bits(N) - 1:0] i_X;
reg [$bits(N * N_CLASSES) - 1:0] i_Theta;
reg [$bits(N_CLASSES) - 1:0] prediction;
reg [3:0] prediction_led;

reg [2:0] state;
localparam GET_X       = 3'd0,
           GET_THETA   = 3'd1,
           PREDICT_IN  = 3'd2,
           PREDICT_OUT = 3'd3,
           PUT_RESULT  = 3'd4;

wire [N - 1:0][31:0] predict_input_X;
wire [N - 1:0][N_CLASSES - 1:0][31:0] predict_input_Theta;
reg predict_input_X_stb, predict_input_Theta_stb;
reg predict_output_prediction_ack;
wire [$bits(N_CLASSES) - 1:0] predict_output_prediction;
wire predict_input_X_ack, predict_input_Theta_ack;
wire predict_output_prediction_stb;

reg predict_read_X_done, predict_read_Theta_done;

assign predict_input_X = X;
assign predict_input_Theta = Theta;


//=======================================================
//  Structural coding
//=======================================================

wire clk;

assign clk = CLOCK_50;

reg [19:0] cnt;
reg	rst;

always @(posedge clk) begin
    if (cnt != 20'hFFFFF) begin
        cnt <= cnt + 1;
        rst <= 1'b1;
    end else begin
        rst <= 1'b0;
    end
end


always @(posedge clk) begin
    if (rst) begin
        state <= GET_X;
        predict_input_X_stb <= 1'b0;
        predict_input_Theta_stb <= 1'b0;
        predict_output_prediction_ack <= 1'b0;
        predict_read_X_done <= 1'b0;
        predict_read_Theta_done <= 1'b0;
        addr <= 8'b0;
        i_X <= {$bits(N){1'b0}};
        i_Theta <= {$bits(N * N_CLASSES){1'b0}};
    end else begin

        case (state)

            GET_X: begin
                X[i_X] <= read_data;
                addr <= addr + 1;
                i_X <= i_X + 1;
                if (i_X == N - 1) begin
                    state <= GET_THETA;
                end
            end

            GET_THETA: begin
                Theta[i_Theta] <= read_data;
                addr <= addr + 1;
                i_Theta <= i_Theta + 1;
                if (i_Theta == N * N_CLASSES - 1) begin
                    state <= PREDICT_IN;
                end
            end

            PREDICT_IN: begin
                if (!predict_read_X_done) begin
                    predict_input_X_stb <= 1'b1;
                end
                if (!predict_read_Theta_done) begin
                    predict_input_Theta_stb <= 1'b1;
                end
                if (predict_input_X_ack && predict_input_X_stb) begin
                    predict_read_X_done <= 1'b1;
                    predict_input_X_stb <= 1'b0;
                end
                if (predict_input_Theta_ack && predict_input_Theta_stb) begin
                    predict_read_Theta_done <= 1'b1;
                    predict_input_Theta_stb <= 1'b0;
                end
                if (predict_read_X_done && predict_read_Theta_done) begin
                    predict_read_X_done <= 1'b0;
                    predict_read_Theta_done <= 1'b0;
                    state <= PREDICT_OUT;
                end
            end

            PREDICT_OUT: begin
                predict_output_prediction_ack <= 1'b1;
                if (predict_output_prediction_ack && predict_output_prediction_stb) begin
                    predict_output_prediction_ack <= 1'b0;
                    prediction <= predict_output_prediction;
                    state <= PUT_RESULT;
                end
            end

            PUT_RESULT: begin
                LEDR[17] <= 1'b1;
                prediction_led <= prediction;
            end

        endcase

    end
end

assign LEDR[3:0] = prediction_led;

ram ram_inst (
	.clock(clk),
	.data(32'b0),
	.rdaddress(addr),
	.wraddress(32'b0),
	.wren(1'b0),
	.q(read_data)
);

logistic_predict #(.N(15), .N_CLASSES(10), .MATMUL_N_INNER_PRODUCTS(1), .MATMUL_IP_N_THRESH(32768)) logistic_predict_inst (
    .clk(clk),
    .rst(rst),
    .input_X(predict_input_X),
    .input_Theta(predict_input_Theta),
    .input_X_stb(predict_input_X_stb),
    .input_Theta_stb(predict_input_Theta_stb),
    .output_prediction(predict_output_prediction),
    .output_prediction_ack(predict_output_prediction_ack),
    .input_X_ack(predict_input_X_ack),
    .input_Theta_ack(predict_input_Theta_ack),
    .output_prediction_stb(predict_output_prediction_stb)
);

endmodule
