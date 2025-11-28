do clean.do
do compile.do
vsim -voptargs=+acc work.tb_reg_piso_n
add wave -r /*
run -all
