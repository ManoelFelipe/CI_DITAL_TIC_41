
# =============================================================
# run_cli.do - Roda em modo console (sem forçar saída)
# Ex.: vsim -c -do scripts/run_cli.do
# =============================================================
do compile.do
vsim work.tb_decodificador_4_16 -do "run -all"
