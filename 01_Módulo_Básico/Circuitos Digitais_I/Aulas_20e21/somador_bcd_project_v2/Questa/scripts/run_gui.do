
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_somador_bcd
add wave -r /*
run -all
