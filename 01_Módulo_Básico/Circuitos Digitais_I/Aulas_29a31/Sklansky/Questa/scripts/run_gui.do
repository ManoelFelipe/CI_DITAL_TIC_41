# Limpa, recompila e roda em GUI
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_Sklansky ;# habilita visibilidade de sinais
add wave -r /*
run -all
