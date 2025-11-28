
# =============================================================
# compile.do - Compila variantes e testbench (sem forçar quit)
# Execute dentro de Questa/scripts:
#    do compile.do
# =============================================================
vlib work
vmap work work

# Ajuste de caminhos relativos a partir de scripts/
vlog ../rtl/behavioral/decodificador_4_16.v
vlog ../rtl/dataflow/decodificador_4_16.v
vlog ../rtl/structural/decodificador_4_16.v
vlog ../tb/tb_decodificador_4_16.v
