# run_gui.do — limpa, compila e executa em modo gráfico
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_pwm_50hz
add wave -r /*
run -all
