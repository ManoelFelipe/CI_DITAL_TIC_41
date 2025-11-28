do clean.do
do compile.do
vsim -voptargs=+acc work.tb_multiplex_8_1
add wave -r /*
run -all
