# compile.do — compila as tres abordagens do conversor Excesso-3
# e o testbench tb_excesso_3 em uma unica biblioteca work.

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Compilacao das tres versoes RTL (behavioral, dataflow, structural)
vlog -work work ../rtl/behavioral/excesso_3.v
vlog -work work ../rtl/dataflow/excesso_3.v
vlog -work work ../rtl/structural/excesso_3.v

# Compilacao do testbench
vlog -work work ../tb/tb_excesso_3.v
