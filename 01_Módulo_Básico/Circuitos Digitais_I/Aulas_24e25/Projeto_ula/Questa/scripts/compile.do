# compile.do — compila as tres abordagens (behavioral, dataflow, structural)
# Ajustado para que o testbench tb_ula instancie simultaneamente todas
# as variantes da ULA, permitindo comparacao cruzada.
if {[file exists work]} { catch {vdel -lib work -all} }
vlib work
vmap work work

# Compila RTL das tres abordagens
vlog -work work ../rtl/behavioral/ula.v
vlog -work work ../rtl/dataflow/ula.v
vlog -work work ../rtl/structural/ula.v

# Compila o testbench
vlog -work work ../tb/tb_ula.v
