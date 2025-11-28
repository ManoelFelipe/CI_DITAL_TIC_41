# Execução em modo console (sem GUI)
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_mux_2_1 -do "run -all; quit"
