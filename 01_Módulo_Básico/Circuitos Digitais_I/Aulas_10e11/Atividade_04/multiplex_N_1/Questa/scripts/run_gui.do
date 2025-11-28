do compile.do
vsim -voptargs=+acc work.tb_multiplex_N_1
add wave -r /*
run -all

