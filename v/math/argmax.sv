module argmax #(parameter N=2) (
    input clk,
    input rst,
    input [N - 1:0][31:0] input_v,
    input input_v_stb,
    input output_i_ack,
    output reg [$bits(N) - 1:0] output_i,
    output reg input_v_ack,
    output reg output_i_stb
);

// TODO: support recursion

reg [1:0] state;
localparam GET_V       = 2'd0,
           COMPARE     = 2'd1,
           PUT_I       = 2'd2;

reg [N - 1:0][31:0] v;

reg [$bits(N) - 1:0] current_argmax, current_i;
reg [31:0] current_max;

wire [31:0] cmp_input_x1;
reg [31:0] cmp_input_x2;
wire [1:0] cmp_output_result;

assign cmp_input_x1 = current_max;

always @(posedge clk) begin
    if (rst) begin
        state <= GET_V;
    end else begin

        case (state)

            GET_V: begin
                input_v_ack <= 1'b1;
                if (input_v_ack && input_v_stb) begin
                    v <= input_v;
                    input_v_ack <= 1'b0;
                    current_argmax <= {($bits(N) - 1){1'b0}};
                    current_i <= {{($bits(N) - 2){1'b0}}, 1'b1};
                    current_max <= input_v[0];
                    cmp_input_x2 <= input_v[1];
                    state <= COMPARE;
                end
            end

            COMPARE: begin
                if (cmp_output_result == 2'b10) begin
                    current_max <= v[current_i];
                    current_argmax <= current_i;
                end
                if (current_i < N - 1) begin
                    cmp_input_x2 <= v[current_i + 1];
                    current_i <= current_i + 1;
                end else begin
                    state <= PUT_I;
                end
            end
            
            PUT_I: begin
                output_i <= current_argmax;
                output_i_stb <= 1'b1;
                if (output_i_ack && output_i_stb) begin
                    output_i_stb <= 1'b0;
                    state <= GET_V;
                end
            end

        endcase

    end
end

cmp cmp_inst (
    .input_x1(cmp_input_x1),
    .input_x2(cmp_input_x2),
    .output_result(cmp_output_result)
);

endmodule
