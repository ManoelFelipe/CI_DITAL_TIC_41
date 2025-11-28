
# =============================================================
# run_cli.do - Execução em modo console (não-GUI)
# Uso: vsim -c -do scripts/run_cli.do
# =============================================================
vsim work.tb_decodificador_4_16 -do "run -all; quit -f"
