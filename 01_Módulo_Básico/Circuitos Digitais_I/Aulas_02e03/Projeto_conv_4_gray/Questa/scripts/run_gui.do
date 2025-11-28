# run_gui.do — abre simulação em modo gráfico
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_conv_4_gray
add wave -r /*
run -all
