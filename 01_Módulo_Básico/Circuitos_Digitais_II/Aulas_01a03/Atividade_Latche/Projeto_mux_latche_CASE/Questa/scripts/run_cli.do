do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_mux_latche_case -do "run -all; quit"
