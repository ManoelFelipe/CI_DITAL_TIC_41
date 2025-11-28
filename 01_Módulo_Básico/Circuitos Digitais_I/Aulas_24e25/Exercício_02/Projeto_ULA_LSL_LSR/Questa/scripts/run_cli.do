# Execução em modo console (sem GUI)
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_ULA_LSL_LSR -do "run -all; quit"
