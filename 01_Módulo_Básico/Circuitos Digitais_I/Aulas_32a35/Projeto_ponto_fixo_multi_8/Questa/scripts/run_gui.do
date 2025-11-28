# run_gui.do
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ponto_fixo_multi_8
add wave -r /*
run -all
