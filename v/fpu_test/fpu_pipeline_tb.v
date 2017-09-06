`timescale 1ns / 1ps

module fpu_tb();

reg clk, rst;
reg [7:0][31:0] a, b;
reg [2:0] i;
reg [31:0] input_a, input_b;
reg input_a_stb, input_b_stb, product_ack;

wire [31:0] sum, product;
wire input_a_ack, input_b_ack, product_stb;

reg input_a_acked, input_b_acked;
reg delay_output;

initial begin
    $dumpvars;
    clk = 0;
    i = 3'd0;
    a = {32'h3F800000, 32'h40000000, 32'hC0400000, 32'hC0800000, 32'h40A00000, 32'h40C00000, 32'h40E00000, 32'h41000000};   // [1, 2, -3, -4, 5, 6, 7, 8]
    b = {32'hC0800000, 32'h40400000, 32'h40000000, 32'hBF800000, 32'h40A00000, 32'h40C00000, 32'h40E00000, 32'h41000000};   // [-4, 3, 2, -1, 5, 6, 7, 8]
    input_a_stb = 0;
    input_b_stb = 0;
    product_ack = 0;
    input_a_acked = 0;
    input_b_acked = 0;
    delay_output = 0;
    forever begin
        #5 clk = ~clk;
    end
end

initial begin
    rst = 1;
    #10 rst = 0;
    #1000 delay_output = 1;
    #1000 delay_output = 0;
    #1000 $finish;
end


multiplier mul(
    .input_a(input_a),
    .input_b(input_b),
    .input_a_stb(input_a_stb),
    .input_b_stb(input_b_stb),
    .output_z_ack(product_ack),
    .clk(clk),
    .rst(rst),
    .output_z(product),
    .output_z_stb(product_stb),
    .input_a_ack(input_a_ack),
    .input_b_ack(input_b_ack)
);


always @(posedge clk) begin

    if (!input_a_acked && !input_a_ack) begin
        input_a <= a[i];
        input_a_stb <= 1'b1;
    end

    if (!input_b_acked && !input_b_ack) begin
        input_b <= b[i];
        input_b_stb <= 1'b1;
    end

    if (input_a_ack) begin
        input_a_acked <= 1'b1;
        input_a_stb <= 1'b0;
    end

    if (input_b_ack) begin
        input_b_acked <= 1'b1;
        input_b_stb <= 1'b0;
    end

    if (input_a_acked && input_b_acked) begin
        input_a_acked <= 1'b0;
        input_b_acked <= 1'b0;
        i <= i + 1;
    end

    if (product_stb && !delay_output) begin
        product_ack <= 1'b1;
    end else begin
        product_ack <= 1'b0;
    end

end

endmodule
