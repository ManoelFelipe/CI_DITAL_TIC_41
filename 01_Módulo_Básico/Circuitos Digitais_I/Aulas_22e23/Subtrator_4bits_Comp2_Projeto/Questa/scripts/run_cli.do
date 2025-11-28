# Execução em modo console (não força saída do aplicativo)
do clean.do
do compile.do
# Simula e permanece apenas no escopo da simulação
vsim -voptargs=+acc work.tb_subtrator_4_cop_2 -c -do "run -all; quit -sim"
