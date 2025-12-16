do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_sistema_memoria -do "run -all; quit -f"
