module cmp (
    input [31:0] input_x1,
    input [31:0] input_x2,
    output reg [1:0] output_result
);

// Compare two floating point numbers;
// output 2'b00 if equal; 2'b01 if x1 is larger; 2'b10 if x2 is larger.

wire sign_x1, sign_x2;
wire [7:0] exp_x1, exp_x2;
wire [22:0] mantissa_x1, mantissa_x2;

assign sign_x1 = input_x1[31];
assign sign_x2 = input_x2[31];
assign exp_x1 = input_x1[30:23];
assign exp_x2 = input_x2[30:23];
assign mantissa_x1 = input_x1[22:0];
assign mantissa_x2 = input_x2[22:0];

always @(*) begin
    if (sign_x1 ^ sign_x2) begin
        output_result <= 2'b01 ^ {2{sign_x1}};
    end else begin
        if (exp_x1 > exp_x2) begin
            output_result <= 2'b01 ^ {2{sign_x1}};
        end else if (exp_x1 < exp_x2) begin
            output_result <= 2'b10 ^ {2{sign_x1}};
        end else begin
            if (mantissa_x1 > mantissa_x2) begin
                output_result <= 2'b01 ^ {2{sign_x1}};
            end else if (mantissa_x1 < mantissa_x2) begin
                output_result <= 2'b10 ^ {2{sign_x1}};
            end else begin
                output_result <= 2'b00;
            end
        end
    end
end

endmodule
