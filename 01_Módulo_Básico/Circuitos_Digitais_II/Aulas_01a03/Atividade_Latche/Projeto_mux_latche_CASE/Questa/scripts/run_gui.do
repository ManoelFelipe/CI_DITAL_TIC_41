do clean.do
do compile.do
vsim -voptargs=+acc work.tb_mux_latche_case
add wave -r /*
run -all
