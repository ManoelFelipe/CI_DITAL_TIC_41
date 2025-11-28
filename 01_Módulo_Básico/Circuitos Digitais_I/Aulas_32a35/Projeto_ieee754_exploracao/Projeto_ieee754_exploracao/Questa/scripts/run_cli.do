do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_ieee754_exploracao -do "run -all; quit -f"
