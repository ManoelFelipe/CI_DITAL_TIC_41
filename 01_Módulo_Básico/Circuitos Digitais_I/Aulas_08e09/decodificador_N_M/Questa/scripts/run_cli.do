
# =============================================================
# run_cli.do - Execução em modo console (sem forçar saída)
# =============================================================
do compile.do
vsim -voptargs=+acc work.tb_decodificador_N_M -do "run -all"
