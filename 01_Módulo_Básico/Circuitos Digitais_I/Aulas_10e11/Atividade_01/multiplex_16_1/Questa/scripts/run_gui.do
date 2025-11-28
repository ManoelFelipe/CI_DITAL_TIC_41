
# Limpa e compila antes de iniciar a GUI
do clean.do
do compile.do

# Abre a simulação com acesso total aos sinais
vsim -voptargs=+acc work.tb_multiplex_16_1

# Adiciona sinais automaticamente ao Wave e inicia
add wave -r /*
run -all
