do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ula_8
add wave -r /*
run -all
