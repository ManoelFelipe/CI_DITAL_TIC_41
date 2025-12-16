do clean.do
do compile.do
vsim -c work.tb_fifo_16_buffer_circular -do "run -all; quit"
