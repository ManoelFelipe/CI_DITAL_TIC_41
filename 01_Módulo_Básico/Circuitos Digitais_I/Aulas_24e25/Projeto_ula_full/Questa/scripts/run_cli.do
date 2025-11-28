do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_ula_full -do "run -all; quit"
