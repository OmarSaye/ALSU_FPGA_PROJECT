vlib work
vlog *.v
vsim -gui -voptargs=+acc work.ALSU_tb
add wave -unsigned *
add wave -unsigned -position insertpoint  \
sim:/ALSU_tb/dut/blink_counter
run -all
