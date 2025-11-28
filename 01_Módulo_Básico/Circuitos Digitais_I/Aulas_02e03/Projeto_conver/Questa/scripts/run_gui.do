# run_gui.do — execução em modo gráfico com waveform
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_conver
add wave -r /*
run -all
