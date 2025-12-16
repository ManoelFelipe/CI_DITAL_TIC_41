do clean.do
do compile.do
vsim -voptargs=+acc work.tb_sistema_memoria
add wave -r /*
run -all
