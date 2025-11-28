
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_carry_look_ahead_adder_4b
add wave -r /*
run -all
