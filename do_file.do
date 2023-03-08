vlib work
vlog *.v
vsim -gui -voptargs=+acc work.ALSU_tb
add wave -unsigned -position insertpoint  \
sim:/ALSU_tb/clk \
sim:/ALSU_tb/i \
sim:/ALSU_tb/j \
sim:/ALSU_tb/opcode_tb \
sim:/ALSU_tb/A_tb \
sim:/ALSU_tb/B_tb \
sim:/ALSU_tb/cin_tb \
sim:/ALSU_tb/serial_in_tb \
sim:/ALSU_tb/direction_tb \
sim:/ALSU_tb/out_dut \
sim:/ALSU_tb/leds_dut \
sim:/ALSU_tb/dut/invalid_counter \
sim:/ALSU_tb/rst_tb \
sim:/ALSU_tb/red_op_A_tb \
sim:/ALSU_tb/red_op_B_tb \
sim:/ALSU_tb/bypass_A_tb \
sim:/ALSU_tb/bypass_B_tb 
run -all
