module inner_product #(parameter N=8) (
    input clk,
    input rst,
    input [N - 1:0][31:0] input_a, input_b,
    input input_a_stb, input_b_stb,
    input output_z_ack,
    output input_a_ack, input_b_ack,
    output [31:0] output_z,
    output output_z_stb
);


generate

    if (N == 1) begin

        // degenerated case: multiplication of numbers
        multiplier mul (
            .input_a(input_a),
            .input_b(input_b),
            .input_a_stb(input_a_stb),
            .input_b_stb(input_b_stb),
            .output_z_ack(output_z_ack),
            .clk(clk),
            .rst(rst),
            .output_z(output_z),
            .output_z_stb(output_z_stb),
            .input_a_ack(input_a_ack),
            .input_b_ack(input_b_ack)
        );

    end else begin

        // divide and conquer

        wire [63:0] sub_products;    // 2 sub-products concatenated

        wire [1:0] sub_mul_input_a_ack, sub_mul_input_b_ack;
        wire [1:0] sub_products_ready;   // each bit indicates the status of a sub_product

        wire sub_add_input_a_ack, sub_add_input_b_ack;

        genvar i;
        for (i = 0; i < 2; i = i + 1) begin : SUB_PRODUCT_MODULE
            localparam SUB_N = (N % 2) ? ((N >> 1) + i) : (N >> 1);
            localparam LO = i * (SUB_N - (N % 2));
            localparam HI = LO + SUB_N - 1;
            inner_product #(.N(SUB_N)) sub_inner_product (
                .clk(clk),
                .rst(rst),
                .input_a(input_a[HI:LO]),
                .input_b(input_b[HI:LO]),
                .input_a_stb(input_a_stb),
                .input_b_stb(input_b_stb),
                .output_z_ack(sub_add_input_a_ack && sub_add_input_b_ack),
                .input_a_ack(sub_mul_input_a_ack[i]),
                .input_b_ack(sub_mul_input_b_ack[i]),
                .output_z(sub_products[32 * i + 31:32 * i]),
                .output_z_stb(sub_products_ready[i])
            );
        end

        adder add (
            .clk(clk),
            .rst(rst),
            .input_a(sub_products[31:0]),
            .input_b(sub_products[63:32]),
            .input_a_stb(sub_products_ready[0]),
            .input_b_stb(sub_products_ready[1]),
            .output_z_ack(output_z_ack),
            .input_a_ack(sub_add_input_a_ack),
            .input_b_ack(sub_add_input_b_ack),
            .output_z(output_z),
            .output_z_stb(output_z_stb)
        );

        assign input_a_ack = &sub_mul_input_a_ack;
        assign input_b_ack = &sub_mul_input_b_ack;

    end

endgenerate

endmodule
