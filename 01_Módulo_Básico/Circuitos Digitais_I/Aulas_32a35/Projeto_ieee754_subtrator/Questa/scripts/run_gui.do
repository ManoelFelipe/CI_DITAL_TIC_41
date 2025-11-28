do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ieee754_subtractor
add wave -r /*
run -all
