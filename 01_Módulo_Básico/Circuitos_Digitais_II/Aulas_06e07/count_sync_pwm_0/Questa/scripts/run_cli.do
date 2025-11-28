# run_cli.do — execução em modo console (sem interface gráfica)
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_pwm_50hz -do "run -all; quit"
