do clean.do
do compile.do
vsim -voptargs=+acc work.tb_wallace
add wave -r /*
run -all
