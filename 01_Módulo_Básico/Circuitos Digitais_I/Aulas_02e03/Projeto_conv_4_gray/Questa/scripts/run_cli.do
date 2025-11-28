# run_cli.do — execução em modo console (sem GUI)
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_conv_4_gray -do "run -all; quit -f"
