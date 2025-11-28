# run_gui.do — roda simulação com interface gráfica

do clean.do
do compile.do
vsim -voptargs=+acc work.tb_count_ascendente_100
add wave -r /*
run -all
