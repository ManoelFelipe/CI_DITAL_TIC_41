# compile.do — compila as 3 implementações + testbench único
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Compila RTL (cada uma tem um nome de módulo distinto no diretório Questa/rtl)
vlog -work work ../rtl/behavioral/regfile8x16c.v
vlog -work work ../rtl/dataflow/regfile8x16c.v
vlog -work work ../rtl/structural/regfile8x16c.v

# Compila testbench
vlog -work work ../tb/tb_regfile8x16c.v
