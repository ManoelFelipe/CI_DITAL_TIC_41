do clean.do
do compile.do
vsim -voptargs=+acc work.tb_mux_2_1
add wave -r /*
run -all
