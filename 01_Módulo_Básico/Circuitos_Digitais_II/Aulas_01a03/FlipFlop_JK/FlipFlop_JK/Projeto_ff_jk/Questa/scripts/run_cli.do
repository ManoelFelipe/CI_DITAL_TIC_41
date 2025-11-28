do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_ff_jk
run -all
quit
