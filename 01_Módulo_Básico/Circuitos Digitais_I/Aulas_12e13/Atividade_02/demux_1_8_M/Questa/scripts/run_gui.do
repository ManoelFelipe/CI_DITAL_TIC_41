
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_demux_1_8_M
add wave -r /*
run -all
