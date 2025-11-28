# Execução em modo CLI (não forçar quit)
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_BrentKungAdder8
run -all
