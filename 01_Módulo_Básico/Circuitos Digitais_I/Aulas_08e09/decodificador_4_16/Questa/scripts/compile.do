
# =============================================================
# compile.do - Compilação das três variantes + testbench
# Uso (CLI): vsim -c -do scripts/compile.do
# =============================================================

vlib work
vmap work work

# Ajuste os caminhos conforme pasta "Questa/rtl/*"
vlog ../rtl/behavioral/decodificador_4_16.v
vlog ../rtl/dataflow/decodificador_4_16.v
vlog ../rtl/structural/decodificador_4_16.v
vlog ../tb/tb_decodificador_4_16.v