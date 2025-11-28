# Executa GUI com limpeza e compilação automáticas
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_subtrator_4_cop_2
add wave -r /*
run -all
