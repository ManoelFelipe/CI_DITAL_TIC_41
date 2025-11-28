# run_cli.do — execucao em modo console (sem GUI)
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_excesso_3 -do "run -all; quit"
