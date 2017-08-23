VERILOG := iverilog
SIMULATOR := vvp
SRCS := fpu_tb.v ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v
OUTPUT := fpu_tb.out

.PHONY: all
all: compile simulate

.PHONY: compile
compile: $(SRCS)
	$(VERILOG) -o $(OUTPUT)  $(SRCS)	

.PHONY: simulate
simulate:
	$(SIMULATOR) $(OUTPUT)

.PHONY : clean
clean:
	$(RM) $(OUTPUT) dump.vcd
