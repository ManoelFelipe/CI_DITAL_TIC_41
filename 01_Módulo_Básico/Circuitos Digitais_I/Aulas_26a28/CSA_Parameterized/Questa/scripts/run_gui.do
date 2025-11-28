# GUI: limpa, compila, abre vsim e prepara ondas
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_csa_parameterized
add wave -r /*
run -all
