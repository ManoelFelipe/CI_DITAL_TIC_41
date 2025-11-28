do clean.do
do compile.do
vsim -voptargs=+acc work.tb_decodificador_2_4
add wave -r /*
run -all
