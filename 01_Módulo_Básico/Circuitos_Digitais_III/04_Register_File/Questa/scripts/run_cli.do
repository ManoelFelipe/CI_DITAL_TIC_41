do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_regfile8x16c -do "run -all; quit -f"
