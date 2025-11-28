do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ULA_LSL_LSR
add wave -r /*
run -all
