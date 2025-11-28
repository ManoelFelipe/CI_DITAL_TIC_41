\
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_csa
add wave -r /*
run -all
