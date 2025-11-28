do clean.do
do compile.do
vsim -voptargs=+acc work.tb_somador_bcd_3
add wave -r /*
run -all
