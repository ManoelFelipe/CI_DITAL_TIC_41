# =====================================================================
# Arquivo : run_cli.do
# Autor   : Manoel Furtado
# Data    : 15/11/2025
# Descricao: Script para executar simulacao em modo console,
#            rodando o testbench tb_ula_full ate o fim.
# Revisao : v1.0 — criacao inicial
# =====================================================================

do clean.do
do compile.do
vsim -c work.tb_ula_full -do "run -all; quit"
