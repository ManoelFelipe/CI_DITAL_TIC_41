do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ula
add wave -r /*
run -all
