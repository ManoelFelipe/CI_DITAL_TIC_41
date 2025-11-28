# run_cli.do
do clean.do
do compile.do
vsim -c -do "run -all; quit -f" work.tb_ponto_fixo_multi_8
