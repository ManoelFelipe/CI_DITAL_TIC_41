do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ponto_fixo_8
add wave -r /*
run -all
