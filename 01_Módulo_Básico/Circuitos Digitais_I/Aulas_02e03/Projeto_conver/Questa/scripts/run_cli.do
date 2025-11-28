# run_cli.do — execução em modo texto (sem interface gráfica)
do clean.do
do compile.do
vsim -c work.tb_conver -do "run -all; quit"
