# run_gui.do — limpa, compila e executa a simulacao em modo GUI
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_excesso_3
add wave -r /*
run -all
