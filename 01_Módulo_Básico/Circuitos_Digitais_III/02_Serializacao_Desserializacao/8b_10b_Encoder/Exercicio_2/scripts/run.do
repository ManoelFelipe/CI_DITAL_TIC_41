# Arquivo: run.do (Exercício 2)
do compile.do

# Simula tb_exercise2 com resolução de 1ps para suportar 1GHz (1ns)
vsim -voptargs=+acc -t 1ps work.tb_exercise2

# Configuração de ondas
delete wave *
add wave -divider "TX Control"
add wave -noupdate /tb_exercise2/clk
add wave -noupdate /tb_exercise2/enable
add wave -noupdate -radix hex /tb_exercise2/tx_data_in
add wave -noupdate /tb_exercise2/tx_inst/load_piso

add wave -divider "Physical Link"
add wave -noupdate /tb_exercise2/tx_wire

add wave -divider "RX Status"
add wave -noupdate /tb_exercise2/rx_inst/aligned
add wave -noupdate /tb_exercise2/rx_valid
add wave -noupdate -radix hex /tb_exercise2/rx_data_out
add wave -noupdate /tb_exercise2/rx_code_err
add wave -noupdate /tb_exercise2/rx_disp_err

wave zoom full
run 200ns
