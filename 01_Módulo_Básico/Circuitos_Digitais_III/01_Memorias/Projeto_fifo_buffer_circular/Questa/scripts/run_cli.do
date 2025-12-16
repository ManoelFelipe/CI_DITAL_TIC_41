
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_fifo_8x8_buffer_circular -do "run -all; quit"
