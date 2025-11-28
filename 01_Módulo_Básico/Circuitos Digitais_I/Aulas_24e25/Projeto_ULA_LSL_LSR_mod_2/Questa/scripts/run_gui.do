
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ULA_LSL_LSR_mod_2
add wave -r /*
run -all
