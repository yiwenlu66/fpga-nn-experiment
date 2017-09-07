VERILOG := iverilog
SIMULATOR := vvp
SRCS_RNG := rng_tb.v rng.v
SRCS_SIGMOID := sigmoid_tb.v sigmoid.v ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v
SRCS_MAT_SIGMOID := mat_sigmoid_tb.sv mat_sigmoid.sv sigmoid.v ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v

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

.PHONY : clean
clean:
	$(RM) *.out dump.vcd
