VERILOG := iverilog
SIMULATOR := vvp
SRCS := rng.v

.PHONY: rng
rng: $(SRCS) rng_tb.v
	$(VERILOG) -o rng_tb.out $(SRCS) rng_tb.v
	$(SIMULATOR) rng_tb.out

.PHONY : clean
clean:
	$(RM) *.out dump.vcd
