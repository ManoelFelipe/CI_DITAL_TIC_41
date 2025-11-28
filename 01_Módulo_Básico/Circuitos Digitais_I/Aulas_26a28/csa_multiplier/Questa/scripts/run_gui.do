\
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_csa_multiplier
add wave -r /*
run -all
