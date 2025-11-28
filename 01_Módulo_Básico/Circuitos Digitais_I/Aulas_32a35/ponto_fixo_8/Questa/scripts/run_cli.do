do clean.do
do compile.do
vsim -c work.tb_ponto_fixo_8 -do "run -all; quit"
