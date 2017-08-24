VERILOG := iverilog
SIMULATOR := vvp
SRCS := inner_product.v mat_product.v ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v

.PHONY: inner_product
inner_product: $(SRCS) inner_product_tb.v
	$(VERILOG) -o inner_product_tb.out $(SRCS) inner_product_tb.v
	$(SIMULATOR) inner_product_tb.out

.PHONY: mat_product
mat_product: $(SRCS) mat_product_tb.v
	$(VERILOG) -o mat_product_tb.out $(SRCS) mat_product_tb.v
	$(SIMULATOR) mat_product_tb.out

.PHONY : clean
clean:
	$(RM) *.out dump.vcd
