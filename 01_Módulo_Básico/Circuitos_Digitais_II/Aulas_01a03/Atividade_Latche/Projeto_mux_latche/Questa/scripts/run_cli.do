do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_mux_latche
run -all
quit -f
