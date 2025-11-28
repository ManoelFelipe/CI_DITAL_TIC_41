# compile.do — compila simultaneamente behavioral, dataflow e structural
# Este script foi adaptado para permitir que o testbench compare
# as três abordagens em uma única simulação.

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Compilação dos três RTLs
vlog -work work ../rtl/behavioral/conv_4_gray.v
vlog -work work ../rtl/dataflow/conv_4_gray.v
vlog -work work ../rtl/structural/conv_4_gray.v

# Compilação do testbench
vlog -work work ../tb/tb_conv_4_gray.v
