do clean.do
do compile.do
vsim -voptargs=+acc work.tb_multiplexador_4_1
add wave -r /*
run -all
