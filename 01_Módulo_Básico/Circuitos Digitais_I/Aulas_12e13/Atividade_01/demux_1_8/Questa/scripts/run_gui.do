# run_gui.do — abre GUI; limpa e compila antes; não força saída do Questa
do clean.do
do compile.do
# Executa com visibilidade de sinais (+acc)
vsim -voptargs=+acc work.tb_demux_1_8
add wave -r /*
run -all
