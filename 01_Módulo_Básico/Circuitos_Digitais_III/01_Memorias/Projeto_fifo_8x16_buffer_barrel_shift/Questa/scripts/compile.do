# compile.do — compila TODAS as implementacoes exigidas (3 DUTs + referencia + TB)
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

vlog -work work ../rtl/behavioral/fifo_8x16_buffer_barrel_shift.v
vlog -work work ../rtl/dataflow/fifo_8x16_buffer_barrel_shift.v
vlog -work work ../rtl/structural/fifo_8x16_buffer_barrel_shift.v

vlog -work work ../rtl/reference/fifo_buffer_circular_behavioral.v

vlog -work work ../tb/tb_fifo_8x16_buffer_barrel_shift.v
