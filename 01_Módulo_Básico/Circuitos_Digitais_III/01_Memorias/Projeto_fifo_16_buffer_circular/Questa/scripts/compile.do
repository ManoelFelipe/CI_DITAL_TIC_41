# compile.do — compila as três implementações e o testbench
if {[file exists work]} { catch {vdel -lib work -all} }
vlib work
vmap work work

# RTL das três abordagens
vlog -work work ../rtl/behavioral/fifo_16_buffer_circular.v
vlog -work work ../rtl/dataflow/fifo_16_buffer_circular.v
vlog -work work ../rtl/structural/fifo_16_buffer_circular.v

# Testbench
vlog -work work ../tb/tb_fifo_16_buffer_circular.v
