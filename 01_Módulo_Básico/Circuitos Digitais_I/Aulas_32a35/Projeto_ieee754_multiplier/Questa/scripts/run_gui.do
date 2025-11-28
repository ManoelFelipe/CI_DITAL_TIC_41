do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ieee754_multiplier
add wave -r /*
run -all
