# compile.do — compila as três implementações e o testbench

quietly if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

vlog -work work ../rtl/behavioral/count_ascendente_100.v
vlog -work work ../rtl/dataflow/count_ascendente_100.v
vlog -work work ../rtl/structural/count_ascendente_100.v
vlog -work work ../tb/tb_count_ascendente_100.v
