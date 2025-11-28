do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_ULA_LSL_LSR_mod -do "run -all; quit"
