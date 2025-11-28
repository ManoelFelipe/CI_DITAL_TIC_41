do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ULA_LSL_LSR_mod
add wave -r /*
run -all
