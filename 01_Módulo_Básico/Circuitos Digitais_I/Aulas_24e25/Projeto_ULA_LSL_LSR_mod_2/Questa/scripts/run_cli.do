
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_ULA_LSL_LSR_mod_2 -do "run -all; quit"
