do clean.do
do compile.do
vsim -voptargs=+acc work.tb_half_adder
add wave -r /*
run -all
