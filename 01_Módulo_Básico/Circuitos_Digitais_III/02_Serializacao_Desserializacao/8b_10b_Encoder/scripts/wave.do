# Arquivo: wave.do
# Limpa ondas antigas
delete wave *

# Adiciona sinais principais com formato e colorização (se aplicavel)
add wave -divider "Clock & Reset"
add wave -noupdate /tb_serdes/clk
add wave -noupdate /tb_serdes/reset
add wave -noupdate /tb_serdes/enable

add wave -divider "TX - Transmissor"
add wave -noupdate -radix hex /tb_serdes/tx_data_in
add wave -noupdate /tb_serdes/tx_inst/load_piso
add wave -noupdate /tb_serdes/tx_inst/bit_counter
add wave -noupdate /tb_serdes/tx_inst/encoded_data

add wave -divider "LINK SERIAL"
add wave -noupdate /tb_serdes/tx_wire

add wave -divider "RX - Receptor"
add wave -noupdate /tb_serdes/rx_inst/aligned
add wave -noupdate -radix binary /tb_serdes/rx_inst/parallel_data
add wave -noupdate -radix hex /tb_serdes/rx_data_out
add wave -noupdate /tb_serdes/rx_valid
add wave -noupdate /tb_serdes/rx_code_err
add wave -noupdate /tb_serdes/rx_disp_err

# Ajusta zoom
wave zoom full
