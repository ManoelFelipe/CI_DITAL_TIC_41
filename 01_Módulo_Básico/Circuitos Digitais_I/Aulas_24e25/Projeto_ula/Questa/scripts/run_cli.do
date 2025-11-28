# run_cli.do — limpa, compila e executa a simulacao em modo batch (sem GUI)
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_ula -do "run -all; quit -f"
