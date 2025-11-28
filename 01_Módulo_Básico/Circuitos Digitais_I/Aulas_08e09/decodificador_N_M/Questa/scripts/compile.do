
# =============================================================
# compile.do - Compila variantes e testbench
# =============================================================
vlib work
vmap work work
vlog ../rtl/behavioral/decodificador_N_M.v
vlog ../rtl/dataflow/decodificador_N_M.v
vlog ../rtl/structural/decodificador_N_M.v
vlog ../tb/tb_decodificador_4_16.v
