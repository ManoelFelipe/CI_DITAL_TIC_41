
# wave.do — prepara a visualização no Questa com sinais organizados e marcadores
# Uso: a partir de Questa na pasta 'Questa/scripts', rode:  do wave.do

# (1) Limpa/compila/instancia a simulação
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_somador_bcd

# (2) Limpa a janela Wave atual
quietly wave clear

# (3) Adiciona sinais organizados por grupos
add wave -group INPUTS sim:/tb_somador_bcd/A
add wave -group INPUTS sim:/tb_somador_bcd/B

add wave -group BEHAVIORAL sim:/tb_somador_bcd/S_beh
add wave -group BEHAVIORAL sim:/tb_somador_bcd/C_beh

add wave -group DATAFLOW sim:/tb_somador_bcd/S_dat
add wave -group DATAFLOW sim:/tb_somador_bcd/C_dat

add wave -group STRUCTURAL sim:/tb_somador_bcd/S_str
add wave -group STRUCTURAL sim:/tb_somador_bcd/C_str

# Internos úteis da versão estrutural (para enxergar correção +6)
add wave -group INTERNAL_STR sim:/tb_somador_bcd/DUT_STR/soma4
add wave -group INTERNAL_STR sim:/tb_somador_bcd/DUT_STR/precisa_corrigir
add wave -group INTERNAL_STR sim:/tb_somador_bcd/DUT_STR/soma_corr
add wave -group INTERNAL_STR sim:/tb_somador_bcd/DUT_STR/Cout

# (4) Radix e estética
radix -decimal
configure wave -namecolwidth 260
configure wave -valuecolwidth 130
configure wave -timeline 1
configure wave -timelineunits ns

# (5) Marcadores das trocas de caso (conforme o TB)
#   t= 5ns : 2 + 3  (sem carry)
#   t=10ns : 4 + 5  (sem correção)
#   t=15ns : 7 + 6  (com correção +6)
#   t=20ns : 9 + 9  (carry alto)
#   t=25ns : 0 + 9
#   t=30ns : 8 + 1
#   t=35ns : 5 + 5
wave marker add -time 5ns  -label {M1 2+3  (sem carry)}
wave marker add -time 10ns -label {M2 4+5  (sem correção)}
wave marker add -time 15ns -label {M3 7+6  (correção +6)}
wave marker add -time 20ns -label {M4 9+9  (carry alto)}
wave marker add -time 25ns -label {M5 0+9}
wave marker add -time 30ns -label {M6 8+1}
wave marker add -time 35ns -label {M7 5+5}

# (6) Zoom inicial útil
WaveRestoreZoom {0ns} {40ns}

# (7) Roda até o fim (o TB tem $finish)
run -all
