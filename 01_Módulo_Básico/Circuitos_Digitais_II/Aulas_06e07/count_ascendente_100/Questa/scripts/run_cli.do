# run_cli.do — executa simulação no modo console

do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_count_ascendente_100 -do "run -all; quit"
