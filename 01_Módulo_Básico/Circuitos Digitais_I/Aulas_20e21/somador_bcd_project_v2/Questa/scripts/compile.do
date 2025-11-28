
# compile.do — compila as 3 implementações simultaneamente (nomes distintos)
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

vlog -work work +define+SOMADOR_NAME=somador_bcd_beh ../rtl/behavioral/somador_bcd.v
vlog -work work +define+SOMADOR_NAME=somador_bcd_dat ../rtl/dataflow/somador_bcd.v
vlog -work work +define+SOMADOR_NAME=somador_bcd_str ../rtl/structural/somador_bcd.v

vlog -work work ../tb/tb_somador_bcd.v
