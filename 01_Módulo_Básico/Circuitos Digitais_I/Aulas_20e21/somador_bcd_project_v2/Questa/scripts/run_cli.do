
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_somador_bcd -do "run -all"
