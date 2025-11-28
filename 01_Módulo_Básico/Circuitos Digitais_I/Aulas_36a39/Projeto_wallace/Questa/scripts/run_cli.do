do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_wallace -do "run -all; quit -f"
