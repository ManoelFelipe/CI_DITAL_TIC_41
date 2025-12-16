
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_fifo_8x8_buffer_circular
add wave -r /*
run -all
