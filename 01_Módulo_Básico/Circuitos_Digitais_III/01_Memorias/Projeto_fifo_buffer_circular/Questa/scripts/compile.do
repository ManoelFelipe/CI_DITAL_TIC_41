
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

vlog -work work ../rtl/behavioral/fifo_8x8_buffer_circular.v
vlog -work work ../rtl/dataflow/fifo_8x8_buffer_circular.v
vlog -work work ../rtl/structural/fifo_8x8_buffer_circular.v

vlog -work work ../tb/tb_fifo_8x8_buffer_circular.v
