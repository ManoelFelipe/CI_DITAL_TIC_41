
# =============================================================
# run_gui.do - Limpa, compila e executa em GUI
# =============================================================
file delete -force work
vlib work
vmap work work
vlog ../rtl/behavioral/decodificador_N_M.v
vlog ../rtl/dataflow/decodificador_N_M.v
vlog ../rtl/structural/decodificador_N_M.v
vlog ../tb/tb_decodificador_4_16.v
vsim -voptargs=+acc work.tb_decodificador_N_M
add wave -r /*
run -all
