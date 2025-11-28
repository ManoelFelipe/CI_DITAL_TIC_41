
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ULA_74181
add wave -r /*
run -all
