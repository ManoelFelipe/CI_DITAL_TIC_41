# ---------------- run_cli.do ----------------
# Execução em modo batch (sem GUI)
do clean.do
do compile.do
vsim -c -do "run -all; quit -f" work.tb_meio_subtrator
