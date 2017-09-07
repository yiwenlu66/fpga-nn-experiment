module sigmoid (
    input clk,
    input rst,
    input [31:0] input_x,
    input input_x_stb,
    input output_s_ack,
    output reg [31:0] output_s,
    output reg input_x_ack,
    output reg output_s_stb
);

// piecewise linear approximation

reg [3:0] state;
localparam GET_X           = 4'd0,
           GET_X_ABS_RANGE = 4'd1,
           GET_COEF        = 4'd2,
           MUL_IN          = 4'd3,
           MUL_OUT         = 4'd4,
           ADD_1_IN        = 4'd5,
           ADD_1_OUT       = 4'd6,
           ADD_2_IN        = 4'd7,
           ADD_2_OUT       = 4'd8,
           PUT_RESULT      = 4'd9;

reg [31:0] x;
wire x_sign;
wire [31:0] x_abs;
wire [7:0] x_exp;
wire [22:0] x_mantissa;

assign x_sign = x[31];
assign x_abs = {1'b0, x[30:0]};
assign x_exp = x[30:23];
assign x_mantissa = x[22:0];

reg [1:0] x_abs_range;
localparam LT_1           = 2'd0,
           GE_1_LT_2_375  = 2'd1,
           GE_2_375_LT_5  = 2'd2,
           GE_5           = 2'd3;

reg [31:0] k, b;
reg [31:0] k_x_abs;
reg [31:0] s_x_abs, s;

reg [31:0] mul_input_a;     // |x|
reg [31:0] mul_input_b;     // k
reg mul_input_a_stb, mul_input_b_stb;
reg mul_output_z_ack;
wire [31:0] mul_output_z;
wire mul_input_a_ack, mul_input_b_ack;
wire mul_output_z_stb;
reg mul_read_a_done, mul_read_b_done;

reg [31:0] add_1_input_a;     // k|x|
reg [31:0] add_1_input_b;     // b
reg add_1_input_a_stb, add_1_input_b_stb;
reg add_1_output_z_ack;
wire [31:0] add_1_output_z;
wire add_1_input_a_ack, add_1_input_b_ack;
wire add_1_output_z_stb;
reg add_1_read_a_done, add_1_read_b_done;

reg [31:0] add_2_input_a;     // -(k|x| + b)
reg [31:0] add_2_input_b;     // 1
reg add_2_input_a_stb, add_2_input_b_stb;
reg add_2_output_z_ack;
wire [31:0] add_2_output_z;
wire add_2_input_a_ack, add_2_input_b_ack;
wire add_2_output_z_stb;
reg add_2_read_a_done, add_2_read_b_done;


always @(posedge clk) begin
    if (rst) begin
        state <= GET_X;
        input_x_ack <= 1'b0;
        output_s_stb <= 1'b0;
        mul_input_a_stb <= 1'b0;
        mul_input_b_stb <= 1'b0;
        mul_output_z_ack <= 1'b0;
        mul_read_a_done <= 1'b0;
        mul_read_b_done <= 1'b0;
        add_1_input_a_stb <= 1'b0;
        add_1_input_b_stb <= 1'b0;
        add_1_output_z_ack <= 1'b0;
        add_1_read_a_done <= 1'b0;
        add_1_read_b_done <= 1'b0;
        add_2_input_a_stb <= 1'b0;
        add_2_input_b_stb <= 1'b0;
        add_2_output_z_ack <= 1'b0;
        add_2_read_a_done <= 1'b0;
        add_2_read_b_done <= 1'b0;
    end else begin

        case (state)

            GET_X: begin
                input_x_ack <= 1'b1;
                if (input_x_ack && input_x_stb) begin
                    x <= input_x;
                    input_x_ack <= 1'b0;
                    state <= GET_X_ABS_RANGE;
                end
            end

            GET_X_ABS_RANGE: begin
                if (x_exp < 8'b01111111) begin
                    x_abs_range <= LT_1;
                end else if (x_exp <= 8'b10000000 && x_mantissa < 23'b00110000000000000000000) begin
                    x_abs_range <= GE_1_LT_2_375;
                end else if (x_exp <= 8'b10000001 && x_mantissa < 23'b01000000000000000000000) begin
                    x_abs_range <= GE_2_375_LT_5;
                end else begin
                    x_abs_range <= GE_5;
                end
                state <= GET_COEF;
            end

            GET_COEF: begin
                case (x_abs_range)
                    LT_1: begin
                        k <= 32'h3e800000;  // 0.25
                        b <= 32'h3f000000;  // 0.5
                    end
                    GE_1_LT_2_375: begin
                        k <= 32'h3e000000;  // 0.125
                        b <= 32'h3f200000;  // 0.625
                    end
                    GE_2_375_LT_5: begin
                        k <= 32'h3d000000;  // 0.03125
                        b <= 32'h3f580000;  // 0.84375
                    end
                    default: begin
                        k <= 32'h0;         // 0
                        b <= 32'h3f800000;  // 1
                    end
                endcase
                state <= MUL_IN;
            end

            MUL_IN: begin
                mul_input_a <= x_abs;
                mul_input_b <= k;
                if (!mul_read_a_done) begin
                    mul_input_a_stb <= 1'b1;
                end
                if (!mul_read_b_done) begin
                    mul_input_b_stb <= 1'b1;
                end
                if (mul_input_a_ack && mul_input_a_stb) begin
                    mul_read_a_done <= 1'b1;
                    mul_input_a_stb <= 1'b0;
                end
                if (mul_input_b_ack && mul_input_b_stb) begin
                    mul_read_b_done <= 1'b1;
                    mul_input_b_stb <= 1'b0;
                end
                if (mul_read_a_done && mul_read_b_done) begin
                    mul_read_a_done <= 1'b0;
                    mul_read_b_done <= 1'b0;
                    state <= MUL_OUT;
                end
            end

            MUL_OUT: begin
                mul_output_z_ack <= 1'b1;
                if (mul_output_z_ack && mul_output_z_stb) begin
                    mul_output_z_ack <= 1'b0;
                    k_x_abs <= mul_output_z;
                    state <= ADD_1_IN;
                end
            end

            ADD_1_IN: begin
                add_1_input_a <= k_x_abs;
                add_1_input_b <= b;
                if (!add_1_read_a_done) begin
                    add_1_input_a_stb <= 1'b1;
                end
                if (!add_1_read_b_done) begin
                    add_1_input_b_stb <= 1'b1;
                end
                if (add_1_input_a_ack && add_1_input_a_stb) begin
                    add_1_read_a_done <= 1'b1;
                    add_1_input_a_stb <= 1'b0;
                end
                if (add_1_input_b_ack && add_1_input_b_stb) begin
                    add_1_read_b_done <= 1'b1;
                    add_1_input_b_stb <= 1'b0;
                end
                if (add_1_read_a_done && add_1_read_b_done) begin
                    add_1_read_a_done <= 1'b0;
                    add_1_read_b_done <= 1'b0;
                    state <= ADD_1_OUT;
                end
            end

            ADD_1_OUT: begin
                add_1_output_z_ack <= 1'b1;
                if (add_1_output_z_ack && add_1_output_z_stb) begin
                    add_1_output_z_ack <= 1'b0;
                    s_x_abs <= add_1_output_z;
                    state <= ADD_2_IN;
                end
            end

            ADD_2_IN: begin
                if (~x_sign) begin
                    // skip this step for positive numbers
                    s <= s_x_abs;
                    state <= PUT_RESULT;
                end else begin

                    add_2_input_a <= {1'b1, s_x_abs[30:0]};     // -(k|x| + b)
                    add_2_input_b <= 32'h3f800000;              // 1
                    if (!add_2_read_a_done) begin
                        add_2_input_a_stb <= 1'b1;
                    end
                    if (!add_2_read_b_done) begin
                        add_2_input_b_stb <= 1'b1;
                    end
                    if (add_2_input_a_ack && add_2_input_a_stb) begin
                        add_2_read_a_done <= 1'b1;
                        add_2_input_a_stb <= 1'b0;
                    end
                    if (add_2_input_b_ack && add_2_input_b_stb) begin
                        add_2_read_b_done <= 1'b1;
                        add_2_input_b_stb <= 1'b0;
                    end
                    if (add_2_read_a_done && add_2_read_b_done) begin
                        add_2_read_a_done <= 1'b0;
                        add_2_read_b_done <= 1'b0;
                        state <= ADD_2_OUT;
                    end
                end
            end

            ADD_2_OUT: begin
                add_2_output_z_ack <= 1'b1;
                if (add_2_output_z_ack && add_2_output_z_stb) begin
                    add_2_output_z_ack <= 1'b0;
                    s <= add_2_output_z;
                    state <= PUT_RESULT;
                end
            end

            PUT_RESULT: begin
                output_s <= s;
                output_s_stb <= 1'b1;
                if (output_s_ack && output_s_stb) begin
                    output_s_stb <= 1'b0;
                    state <= GET_X;
                end
            end

        endcase

    end
end


multiplier mul (
    .clk(clk),
    .rst(rst),
    .input_a(mul_input_a),
    .input_b(mul_input_b),
    .input_a_stb(mul_input_a_stb),
    .input_b_stb(mul_input_b_stb),
    .output_z_ack(mul_output_z_ack),
    .output_z(mul_output_z),
    .input_a_ack(mul_input_a_ack),
    .input_b_ack(mul_input_b_ack),
    .output_z_stb(mul_output_z_stb)
);

adder add_1 (
    .clk(clk),
    .rst(rst),
    .input_a(add_1_input_a),
    .input_b(add_1_input_b),
    .input_a_stb(add_1_input_a_stb),
    .input_b_stb(add_1_input_b_stb),
    .output_z_ack(add_1_output_z_ack),
    .output_z(add_1_output_z),
    .input_a_ack(add_1_input_a_ack),
    .input_b_ack(add_1_input_b_ack),
    .output_z_stb(add_1_output_z_stb)
);

adder add_2 (
    .clk(clk),
    .rst(rst),
    .input_a(add_2_input_a),
    .input_b(add_2_input_b),
    .input_a_stb(add_2_input_a_stb),
    .input_b_stb(add_2_input_b_stb),
    .output_z_ack(add_2_output_z_ack),
    .output_z(add_2_output_z),
    .input_a_ack(add_2_input_a_ack),
    .input_b_ack(add_2_input_b_ack),
    .output_z_stb(add_2_output_z_stb)
);

endmodule
