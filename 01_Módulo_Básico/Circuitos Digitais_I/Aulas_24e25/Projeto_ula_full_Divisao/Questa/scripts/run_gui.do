# =====================================================================
# Arquivo : run_gui.do
# Autor   : Manoel Furtado
# Data    : 15/11/2025
# Descricao: Script para executar simulacao em modo grafico,
#            abrindo a waveform e rodando o testbench tb_ula_full.
# Revisao : v1.0 — criacao inicial
# =====================================================================

do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ula_full
add wave -r /*
run -all
