module inner_product #(parameter N=1,
                                 N_THRESH=1) (
    input clk,
    input rst,
    input [N - 1:0][31:0] input_v1, input_v2,
    input input_v1_stb, input_v2_stb,
    input output_prod_ack,
    output input_v1_ack, input_v2_ack,
    output [31:0] output_prod,
    output output_prod_stb
);

// bisect the vectors for parallel processing until the length of each
// sub-vector <= N_THRESH

generate

    if (N <= N_THRESH) begin

        // serial processing
        
        reg _input_v1_ack, _input_v2_ack;
        reg [31:0] _output_prod;
        reg _output_prod_stb;

        assign input_v1_ack = _input_v1_ack;
        assign input_v2_ack = _input_v2_ack;
        assign output_prod = _output_prod;
        assign output_prod_stb = _output_prod_stb;
        
        reg [2:0] state;
        localparam GET_V1       = 3'd0,
                   GET_V2       = 3'd1,
                   PIPELINE_IN  = 3'd2,
                   PIPELINE_OUT = 3'd3,
                   PUT_PROD     = 3'd4;

        reg [$bits(N_THRESH):0] stage;  // 0, 1, ..., N_THRESH

        reg [N - 1:0][31:0] v1, v2;
        reg [31:0] mul_input_a, mul_input_b, add_input_a, add_input_b;
        reg mul_input_a_stb, mul_input_b_stb, add_input_a_stb, add_input_b_stb;
        reg mul_output_z_ack, add_output_z_ack;
        wire mul_input_a_ack, mul_input_b_ack, add_input_a_ack, add_input_b_ack;
        wire [31:0] mul_output_z, add_output_z;
        reg [31:0] mul_output_z_buf, add_output_z_buf;
        wire mul_output_z_stb, add_output_z_stb;

        reg mul_read_a_done, mul_read_b_done, mul_write_z_done,
            add_read_a_done, add_read_b_done, add_write_z_done;

        reg [31:0] partial_sum, elem_prod;

        always @(posedge clk) begin
            if (rst) begin
                state <= GET_V1;
                stage <= {($bits(N_THRESH) + 1){1'b0}};
                mul_input_a_stb <= 1'b0;
                mul_input_b_stb <= 1'b0;
                add_input_a_stb <= 1'b0;
                add_input_b_stb <= 1'b0;
                mul_output_z_ack <= 1'b0;
                add_output_z_ack <= 1'b0;
                mul_read_a_done <= 1'b0;
                mul_read_b_done <= 1'b0;
                mul_write_z_done <= 1'b0;
                add_read_a_done <= 1'b0;
                add_read_a_done <= 1'b0;
                add_write_z_done <= 1'b0;
            end else begin
                case (state)

                    GET_V1: begin
                        _input_v1_ack <= 1'b1;
                        if (_input_v1_ack && input_v1_stb) begin
                            v1 <= input_v1;
                            _input_v1_ack <= 1'b0;
                            state <= GET_V2;
                        end
                    end

                    GET_V2: begin
                        _input_v2_ack <= 1'b1;
                        if (_input_v2_ack && input_v2_stb) begin
                            v2 <= input_v2;
                            _input_v2_ack <= 1'b0;
                            state <= PIPELINE_IN;
                        end
                    end

                    PIPELINE_IN: begin

                        if (stage < N_THRESH) begin
                            mul_input_a <= v1[stage];
                            mul_input_b <= v2[stage];
                            if (!mul_read_a_done) begin
                                mul_input_a_stb <= 1'b1;
                            end
                            if (!mul_read_a_done) begin
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
                        end else begin
                            // no need for multiplier
                            mul_read_a_done <= 1'b1;
                            mul_read_b_done <= 1'b1;
                            mul_input_a_stb <= 1'b0;
                            mul_input_b_stb <= 1'b0;
                        end

                        if (stage >= 2) begin
                            add_input_a <= partial_sum;
                            add_input_b <= elem_prod;
                            if (!add_read_a_done) begin
                                add_input_a_stb <= 1'b1;
                            end
                            if (!add_read_a_done) begin
                                add_input_b_stb <= 1'b1;
                            end
                            if (add_input_a_ack && add_input_a_stb) begin
                                add_read_a_done <= 1'b1;
                                add_input_a_stb <= 1'b0;
                            end
                            if (add_input_b_ack && add_input_b_stb) begin
                                add_read_b_done <= 1'b1;
                                add_input_b_stb <= 1'b0;
                            end
                        end else begin
                            // no need for adder
                            add_read_a_done <= 1'b1;
                            add_read_b_done <= 1'b1;
                            add_input_a_stb <= 1'b0;
                            add_input_b_stb <= 1'b0;
                        end

                        if (mul_read_a_done && mul_read_b_done && add_read_a_done && add_read_b_done) begin
                            mul_read_a_done <= 1'b0;
                            mul_read_b_done <= 1'b0;
                            add_read_a_done <= 1'b0;
                            add_read_b_done <= 1'b0;
                            state <= PIPELINE_OUT;
                        end

                    end

                    PIPELINE_OUT: begin
                        if (!mul_write_z_done) begin
                            mul_output_z_ack <= 1'b1;
                        end
                        if (!add_write_z_done) begin
                            add_output_z_ack <= 1'b1;
                        end
                        if (mul_output_z_ack && mul_output_z_stb) begin
                            mul_output_z_buf <= mul_output_z;
                            mul_output_z_ack <= 1'b0;
                            mul_write_z_done <= 1'b1;
                        end
                        if (add_output_z_ack && add_output_z_stb) begin
                            add_output_z_buf <= add_output_z;
                            add_output_z_ack <= 1'b0;
                            add_write_z_done <= 1'b1;
                        end

                        if (stage <= 1) begin
                            add_output_z_ack <= 1'b0;
                            add_write_z_done <= 1'b1;   // output of adder not needed
                        end 
                        
                        if (stage == N_THRESH) begin
                            mul_output_z_ack <= 1'b0;
                            mul_write_z_done <= 1'b1;   // output of multiplier not needed
                        end

                        if (mul_write_z_done && add_write_z_done) begin
                            mul_write_z_done <= 1'b0;
                            add_write_z_done <= 1'b0;
                            case (stage)
                                0: partial_sum <= 32'b0;
                                1: partial_sum <= elem_prod;
                                default: partial_sum <= add_output_z_buf;
                            endcase
                            elem_prod <= mul_output_z_buf;
                            if (stage == N_THRESH) begin
                                stage <= {($bits(N_THRESH) + 1){1'b0}};
                                state <= PUT_PROD;
                            end else begin
                                stage <= stage + 1;
                                state <= PIPELINE_IN;
                            end
                        end
                    end

                    PUT_PROD: begin
                        _output_prod <= partial_sum;
                        _output_prod_stb <= 1'b1;
                        if (_output_prod_stb && output_prod_ack) begin
                            _output_prod_stb <= 1'b0;
                            state <= GET_V1;
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

        adder add (
            .clk(clk),
            .rst(rst),
            .input_a(add_input_a),
            .input_b(add_input_b),
            .input_a_stb(add_input_a_stb),
            .input_b_stb(add_input_b_stb),
            .output_z_ack(add_output_z_ack),
            .output_z(add_output_z),
            .input_a_ack(add_input_a_ack),
            .input_b_ack(add_input_b_ack),
            .output_z_stb(add_output_z_stb)
        );

    end else begin

        // divide and conquer

        wire [63:0] sub_inner_products;    // 2 sub-inner-products concatenated

        wire [1:0] sub_ip_input_v1_ack, sub_ip_input_v2_ack;
        wire [1:0] sub_ip_output_prod_stb;   // each bit indicates the status of a sub_product

        wire add_input_a_ack, add_input_b_ack;

        genvar i;
        for (i = 0; i < 2; i = i + 1) begin : SUB_PRODUCT_MODULE
            localparam SUB_N = (N % 2) ? ((N >> 1) + i) : (N >> 1);
            localparam LO = i * (SUB_N - (N % 2));
            localparam HI = LO + SUB_N - 1;
            inner_product #(.N(SUB_N), .N_THRESH(N_THRESH)) sub_inner_product_unit (
                .clk(clk),
                .rst(rst),
                .input_v1(input_v1[HI:LO]),
                .input_v2(input_v2[HI:LO]),
                .input_v1_stb(input_v1_stb),
                .input_v2_stb(input_v2_stb),
                .output_prod_ack(i ? add_input_b_ack : add_input_a_ack),
                .input_v1_ack(sub_ip_input_v1_ack[i]),
                .input_v2_ack(sub_ip_input_v2_ack[i]),
                .output_prod(sub_inner_products[32 * i + 31:32 * i]),
                .output_prod_stb(sub_ip_output_prod_stb[i])
            );
        end

        adder add (
            .clk(clk),
            .rst(rst),
            .input_a(sub_inner_products[31:0]),
            .input_b(sub_inner_products[63:32]),
            .input_a_stb(sub_ip_output_prod_stb[0]),
            .input_b_stb(sub_ip_output_prod_stb[1]),
            .output_z_ack(output_prod_ack),
            .input_a_ack(add_input_a_ack),
            .input_b_ack(add_input_b_ack),
            .output_z(output_prod),
            .output_z_stb(output_prod_stb)
        );

        assign input_v1_ack = &sub_ip_input_v1_ack;
        assign input_v2_ack = &sub_ip_input_v2_ack;

    end

endgenerate

endmodule
