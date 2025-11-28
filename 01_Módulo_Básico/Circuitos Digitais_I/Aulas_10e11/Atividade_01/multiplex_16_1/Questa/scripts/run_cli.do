
# Execução em modo texto (CLI). Não força o encerramento do Questa.
vsim -voptargs=+acc work.tb_multiplex_16_1
run -all
