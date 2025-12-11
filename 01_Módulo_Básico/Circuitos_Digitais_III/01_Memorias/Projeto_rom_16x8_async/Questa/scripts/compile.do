# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION all

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Compila sempre as três implementações para permitir testes simultâneos
vlog -work work ../rtl/behavioral/rom_16x8_async/rom_16x8_async_behavioral.v
vlog -work work ../rtl/dataflow/rom_16x8_async/rom_16x8_async_dataflow.v
vlog -work work ../rtl/structural/rom_16x8_async/rom_16x8_async_structural.v

# Compila o testbench
vlog -work work ../tb/tb_rom_16x8_async.v



