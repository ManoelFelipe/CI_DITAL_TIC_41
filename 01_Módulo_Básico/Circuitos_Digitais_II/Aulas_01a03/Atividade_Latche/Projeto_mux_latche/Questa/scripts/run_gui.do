do clean.do
do compile.do
vsim -voptargs=+acc work.tb_mux_latche
add wave -r /*
run -all
