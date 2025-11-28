\
# Execução em modo console (não força saída do Questa)
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_csa_multiplier -do "run -all"
