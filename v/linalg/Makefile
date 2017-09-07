VERILOG := iverilog
SIMULATOR := vvp
SRCS := inner_product.v mat_product.v mat_sum.v mat_transpose.v ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v
SRCS_INNER_PRODUCT := inner_product.sv inner_product_tb.sv ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v
SRCS_MAT_MUL_SCALAR := mat_mul_scalar_tb.sv mat_mul_scalar.sv ../fpu/multiplier/multiplier.v

.PHONY: inner_product
inner_product: $(SRCS_INNER_PRODUCT)
	$(VERILOG) -o inner_product_tb.out $(SRCS_INNER_PRODUCT)
	$(SIMULATOR) inner_product_tb.out

.PHONY: mat_product
mat_product: $(SRCS) mat_product_tb.v
	$(VERILOG) -o mat_product_tb.out $(SRCS) mat_product_tb.v
	$(SIMULATOR) mat_product_tb.out

.PHONY: mat_sum
mat_sum: $(SRCS) mat_sum_tb.v
	$(VERILOG) -o mat_sum_tb.out $(SRCS) mat_sum_tb.v
	$(SIMULATOR) mat_sum_tb.out

.PHONY: mat_transpose
mat_transpose: $(SRCS) mat_sum_tb.v
	$(VERILOG) -o mat_transpose_tb.out mat_transpose.v mat_transpose_tb.v
	$(SIMULATOR) mat_transpose_tb.out

.PHONY: mat_mul_scalar
mat_mul_scalar: $(SRCS_MAT_MUL_SCALAR)
	$(VERILOG) -o mat_mul_scalar.out $(SRCS_MAT_MUL_SCALAR)
	$(SIMULATOR) mat_mul_scalar.out

.PHONY : clean
clean:
	$(RM) *.out dump.vcd
