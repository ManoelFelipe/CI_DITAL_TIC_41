# =====================================================================
# Arquivo : compile.do
# Autor   : Manoel Furtado
# Data    : 15/11/2025
# Descricao: Compilacao das tres abordagens da ULA_FULL (behavioral,
#            dataflow e structural) e do testbench tb_ula_full.
# Revisao : v1.0 — criacao inicial
# =====================================================================

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

vlog -work work ../rtl/behavioral/ula_full.v
vlog -work work ../rtl/dataflow/ula_full.v
vlog -work work ../rtl/structural/ula_full.v
vlog -work work ../tb/tb_ula_full.v
