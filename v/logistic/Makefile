VERILOG := iverilog
SIMULATOR := vvp
SRCS_PREDICT := logistic_predict_tb.sv logistic_predict.sv ../math/argmax.sv ../math/cmp.v ../linalg/mat_product.sv ../linalg/inner_product.sv ../linalg/mat_transpose.sv ../fpu/adder/adder.v ../fpu/multiplier/multiplier.v

.PHONY: predict
predict: $(SRCS_PREDICT)
	$(VERILOG) -o predict_tb.out $(SRCS_PREDICT)
	$(SIMULATOR) predict_tb.out

.PHONY : clean
clean:
	$(RM) *.out dump.vcd
