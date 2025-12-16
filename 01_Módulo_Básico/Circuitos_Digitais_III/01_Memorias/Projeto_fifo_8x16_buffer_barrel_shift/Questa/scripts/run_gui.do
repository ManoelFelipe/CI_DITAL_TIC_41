do clean.do
do compile.do
vsim -voptargs=+acc work.tb_fifo_8x16_buffer_barrel_shift
add wave -r /*
run -all
