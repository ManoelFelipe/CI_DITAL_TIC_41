# compile.do — compila as três abordagens (behavioral, dataflow, structural)
# e o testbench tb_conver em uma única biblioteca work.

# Garante que a biblioteca exista.
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Compila as três implementações do conversor.
vlog -work work ../rtl/behavioral/conver.v
vlog -work work ../rtl/dataflow/conver.v
vlog -work work ../rtl/structural/conver.v

# Compila o testbench.
vlog -work work ../tb/tb_conver.v
