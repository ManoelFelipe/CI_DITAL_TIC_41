do clean.do
do compile.do
vsim -voptargs=+acc work.tb_full_adder_4bits
add wave -r /*
run -all
