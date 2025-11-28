# Execução em GUI — limpa, compila e abre simulação
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_BrentKungAdder8
add wave -r /*
run -all
