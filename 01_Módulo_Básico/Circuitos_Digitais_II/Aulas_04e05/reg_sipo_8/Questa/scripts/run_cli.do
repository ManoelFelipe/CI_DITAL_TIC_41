do clean.do
do compile.do

vsim -c -voptargs=+acc work.tb_reg_sipo_8
run -all
quit -f
