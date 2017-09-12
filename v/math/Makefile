VERILOG := iverilog
SIMULATOR := vvp
SRCS_CMP := cmp_tb.v cmp.v
SRCS_RNG := rng_tb.v rng.v
SRCS_SIGMOID := sigmoid_tb.v sigmoid.v ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v
SRCS_MAT_SIGMOID := mat_sigmoid_tb.sv mat_sigmoid.sv sigmoid.v ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v
SRCS_ARGMAX := argmax_tb.v argmax.sv cmp.v

.PHONY: cmp
cmp: $(SRCS_CMP)
	$(VERILOG) -o cmp_tb.out $(SRCS_CMP)
	$(SIMULATOR) cmp_tb.out

.PHONY: rng
rng: $(SRCS_RNG)
	$(VERILOG) -o rng_tb.out $(SRCS_RNG)
	$(SIMULATOR) rng_tb.out

.PHONY: sigmoid
sigmoid: $(SRCS_SIGMOID)
	$(VERILOG) -o sigmoid_tb.out $(SRCS_SIGMOID)
	$(SIMULATOR) sigmoid_tb.out

.PHONY: mat_sigmoid
mat_sigmoid: $(SRCS_MAT_SIGMOID)
	$(VERILOG) -o mat_sigmoid_tb.out $(SRCS_MAT_SIGMOID)
	$(SIMULATOR) mat_sigmoid_tb.out

.PHONY: argmax
argmax: $(SRCS_ARGMAX)
	$(VERILOG) -o argmax_tb.out $(SRCS_ARGMAX)
	$(SIMULATOR) argmax_tb.out

.PHONY : clean
clean:
	$(RM) *.out dump.vcd
