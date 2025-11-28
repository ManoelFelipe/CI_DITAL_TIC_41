do clean.do
do compile.do

# Ajuste o nome do testbench conforme o projeto
vsim -voptargs=+acc work.tb_reg_sipo_8
add wave -r /*
run -all
