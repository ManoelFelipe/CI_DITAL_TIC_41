do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_ram_16x8_sync -do "run -all; quit"
