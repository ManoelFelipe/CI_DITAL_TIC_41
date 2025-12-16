# Arquivo: run.do
# Roda a compilação
do compile.do

# Inicia a simulação com otimização +acc (necessário para ver ondas em alguns casos)
vsim -voptargs=+acc work.tb_serdes

# Adiciona ondas (usa script separado se desejar)
do wave.do

# Roda a simulação por tempo suficiente (ex: 5us)
run 5us
