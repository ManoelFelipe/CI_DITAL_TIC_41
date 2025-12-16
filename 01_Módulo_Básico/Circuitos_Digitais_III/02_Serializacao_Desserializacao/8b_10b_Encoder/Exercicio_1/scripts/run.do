# Arquivo: run.do (Exercício 1)
do compile.do

# Simula o testbench fornecido
vsim -voptargs=+acc work.test_8b10b

# Adiciona ondas relevantes para análise do cascateamento
delete wave *
add wave -divider "Inputs"
add wave -noupdate /test_8b10b/testin
add wave -noupdate /test_8b10b/dispin

add wave -divider "Encoder Output"
add wave -noupdate -radix binary /test_8b10b/testout
add wave -noupdate /test_8b10b/dispout

add wave -divider "Decoder Output"
add wave -noupdate /test_8b10b/decodeout
add wave -noupdate /test_8b10b/decodedisp

add wave -divider "Errors"
add wave -noupdate /test_8b10b/decodeerr
add wave -noupdate /test_8b10b/disperr

wave zoom full
run -all
