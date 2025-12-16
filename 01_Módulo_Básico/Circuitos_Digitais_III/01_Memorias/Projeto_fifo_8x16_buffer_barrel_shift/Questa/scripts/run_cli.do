do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_fifo_8x16_buffer_barrel_shift -do "run -all; quit -f"
