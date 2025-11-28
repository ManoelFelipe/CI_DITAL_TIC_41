\
# Execução em modo console (não força encerramento do simulador externo)
onerror {resume}
vsim -c -voptargs=+acc work.tb_csa -do "run -all"
