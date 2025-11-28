# Simulação em modo CLI — não força saída do vsim
do compile.do
vsim -c -voptargs=+acc work.tb_csa_parameterized
run -all
