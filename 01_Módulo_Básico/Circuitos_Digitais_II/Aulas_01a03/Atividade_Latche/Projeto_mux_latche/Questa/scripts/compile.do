# compile.do — Compila tudo (Behavioral, Dataflow, Structural e TB)

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Compila as três implementações
vlog -work work ../rtl/behavioral/mux_latche.v
vlog -work work ../rtl/dataflow/mux_latche.v
vlog -work work ../rtl/structural/mux_latche.v

# Compila o Testbench (que instancia as três)
vlog -work work ../tb/tb_mux_latche.v
