VERILOG := iverilog
SIMULATOR := vvp
SRCS := fpu_tb.v ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v
SRCS_PIPELINE := fpu_pipeline_tb.v ../fpu/multiplier/multiplier.v
OUTPUT := fpu_tb.out

.PHONY: all
all: compile simulate

.PHONY: pipeline
pipeline: compile_pipeline simulate

.PHONY: compile
compile: $(SRCS)
	$(VERILOG) -o $(OUTPUT)  $(SRCS)	

.PHONY: compile_pipeline
compile_pipeline: $(SRCS_PIPELINE)
	$(VERILOG) -o $(OUTPUT)  $(SRCS_PIPELINE)	

.PHONY: simulate
simulate:
	$(SIMULATOR) $(OUTPUT)

.PHONY : clean
clean:
	$(RM) $(OUTPUT) dump.vcd
