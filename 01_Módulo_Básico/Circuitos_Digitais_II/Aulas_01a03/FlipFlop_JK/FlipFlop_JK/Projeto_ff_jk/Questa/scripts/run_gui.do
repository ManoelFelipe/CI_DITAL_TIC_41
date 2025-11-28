do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ff_jk
add wave -r /*
run -all
