do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_somador_carry_look_ahead_param -do "run -all; quit -f"
