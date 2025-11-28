
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ula_datapath
add wave -r /*
run -all
