do clean.do
do compile.do
vsim -voptargs=+acc work.tb_somador_carry_look_ahead_param
add wave -r /*
run -all
