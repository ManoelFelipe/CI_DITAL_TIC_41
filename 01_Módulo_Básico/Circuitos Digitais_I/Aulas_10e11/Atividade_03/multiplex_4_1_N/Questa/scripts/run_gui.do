
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_multiplex_4_1_N
add wave -r /*
run -all
