do clean.do
do compile.do
vsim -voptargs=+acc work.tb_KoggeStone
add wave -r /*
run -all