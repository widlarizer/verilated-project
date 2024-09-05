MODULE=alu

.PHONY:sim verilate build waves lint clean

sim: waveform.vcd
verilate: .stamp.verilate
build: obj_dir/Valu

waves: waveform.vcd
	@echo
	@echo "### PLOTTING WAVES ###"
	gtkwave -6 waveform.vcd

waveform.vcd: ./obj_dir/V$(MODULE)
	@echo
	@echo "### SIMULATING TESTBENCH ###"
	@./obj_dir/V$(MODULE) +verilator+rand+reset+2

./obj_dir/V$(MODULE): .stamp.verilate
	@echo
	@echo "### BUILDING SIMULATION ###"
	make -j -C obj_dir -f V$(MODULE).mk V$(MODULE)

.stamp.verilate: $(MODULE).sv $(MODULE)_tb.cpp
	@echo
	@echo "### VERILATING ###"
	verilator -CFLAGS -std=c++14 -Wall --trace --x-assign unique --x-initial unique -cc $(MODULE).sv --exe $(MODULE)_tb.cpp
	@touch .stamp.verilate

lint: $(MODULE).sv
	verilator --lint-only $(MODULE).sv

clean:
	rm -rf .stamp.*;
	rm -rf ./obj_dir
	rm -rf waveform.vcd

bear:
	bear -- make sim
	make clean
