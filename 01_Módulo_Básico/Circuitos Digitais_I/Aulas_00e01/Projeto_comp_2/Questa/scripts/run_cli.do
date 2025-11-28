# run_cli.do — execução em modo não interativo (linha de comando)

do clean.do
do compile.do

# Simula sem abrir a interface gráfica
vsim -c -voptargs=+acc work.tb_comp_2 -do "run -all; quit -sim"
