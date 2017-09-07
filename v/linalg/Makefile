VERILOG := iverilog
SIMULATOR := vvp
SRCS_INNER_PRODUCT := inner_product_tb.sv inner_product.sv ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v
SRCS_MAT_PRODUCT := mat_product_tb.sv mat_product.sv mat_transpose.sv inner_product.sv ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v
SRCS_MAT_SUM := mat_sum_tb.sv mat_sum.sv ../fpu/adder/adder.v
SRCS_MAT_TRANSPOSE := mat_transpose_tb.sv mat_transpose.sv
SRCS_MAT_MUL_SCALAR := mat_mul_scalar_tb.sv mat_mul_scalar.sv ../fpu/multiplier/multiplier.v

.PHONY: inner_product
inner_product: $(SRCS_INNER_PRODUCT)
	$(VERILOG) -o inner_product_tb.out $(SRCS_INNER_PRODUCT)
	$(SIMULATOR) inner_product_tb.out

.PHONY: mat_product
mat_product: $(SRCS_MAT_PRODUCT)
	$(VERILOG) -o mat_product_tb.out $(SRCS_MAT_PRODUCT)
	$(SIMULATOR) mat_product_tb.out

.PHONY: mat_sum
mat_sum: $(SRCS_MAT_SUM)
	$(VERILOG) -o mat_sum_tb.out $(SRCS_MAT_SUM)
	$(SIMULATOR) mat_sum_tb.out

.PHONY: mat_transpose
mat_transpose: $(SRCS_MAT_TRANSPOSE)
	$(VERILOG) -o mat_transpose_tb.out $(SRCS_MAT_TRANSPOSE)
	$(SIMULATOR) mat_transpose_tb.out

.PHONY: mat_mul_scalar
mat_mul_scalar: $(SRCS_MAT_MUL_SCALAR)
	$(VERILOG) -o mat_mul_scalar.out $(SRCS_MAT_MUL_SCALAR)
	$(SIMULATOR) mat_mul_scalar.out

.PHONY : clean
clean:
	$(RM) *.out dump.vcd
