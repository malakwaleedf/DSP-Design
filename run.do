vlib work
vlog reg_mux.v design_code.v testbench.v
vsim -voptargs=+acc work.DSP48A1_tb
add wave *
run -all
#quit -sim