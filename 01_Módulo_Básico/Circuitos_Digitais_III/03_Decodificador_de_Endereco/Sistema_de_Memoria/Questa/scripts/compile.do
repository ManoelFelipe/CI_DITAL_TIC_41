# compile.do — compila as 3 implementações + testbench
# Observação: Como o testbench instancia simultaneamente as três DUTs, todas as
# RTLs devem ser compiladas juntas no mesmo work.

if {[file exists work_lib]} { vdel -lib work_lib -all }
vlib work_lib
vmap work work_lib

# RTLs
vlog -work work ../rtl/behavioral/sistema_memoria.v
vlog -work work ../rtl/dataflow/sistema_memoria.v
vlog -work work ../rtl/structural/sistema_memoria.v

# Testbench
vlog -work work ../tb/tb_sistema_memoria.v
