do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ieee754_exploracao
add wave -r /*
run -all
