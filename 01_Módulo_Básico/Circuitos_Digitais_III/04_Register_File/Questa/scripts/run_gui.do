do clean.do
do compile.do
vsim -voptargs=+acc work.tb_regfile8x16c
add wave -r /*
run -all
