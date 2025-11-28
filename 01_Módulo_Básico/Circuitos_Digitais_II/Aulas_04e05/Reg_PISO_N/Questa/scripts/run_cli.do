do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_reg_piso_n
run -all
quit
