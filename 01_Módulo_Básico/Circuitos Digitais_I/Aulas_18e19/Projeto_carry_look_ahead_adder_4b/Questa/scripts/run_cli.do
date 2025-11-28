
# Execução em modo console (sem GUI)
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_carry_look_ahead_adder_4b -do "run -all; quit -f"
