
# Arquivo: run_challenge_gui.do
# Executa a simulação do desafio extra com interface gráfica

do compile_challenge.do

vsim -voptargs=+acc work.tb_top_pwm_challenge

# Adiciona ondas
add wave -position insertpoint sim:/tb_top_pwm_challenge/*
add wave -position insertpoint sim:/tb_top_pwm_challenge/u_top/duty_sel
add wave -position insertpoint sim:/tb_top_pwm_challenge/u_top/u_pwm_ch1/counter

# Configura tempo de simulação ou run -all
# Como o testbench tem $finish, run -all é apropriado
run -all
