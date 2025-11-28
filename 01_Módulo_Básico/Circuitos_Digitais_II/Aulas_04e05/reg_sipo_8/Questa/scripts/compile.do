# compile.do — Compila TODAS as abordagens para verificação simultânea
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Compilação dos RTLs (Behavioral, Dataflow, Structural)
vlog -work work ../rtl/behavioral/*.v
vlog -work work ../rtl/dataflow/*.v
vlog -work work ../rtl/structural/*.v

# Compilação do Testbench
vlog -work work ../tb/tb_*.v
