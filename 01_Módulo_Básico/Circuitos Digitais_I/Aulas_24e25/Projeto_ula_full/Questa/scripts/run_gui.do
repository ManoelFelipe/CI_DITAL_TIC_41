do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ula_full
add wave -r /*
run -all
