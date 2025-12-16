# Arquivo: compile.do
# Cria bibliotecas de trabalho
vlib work
vmap work work

# Compila arquivos RTL
vlog -work work ../rtl/encode.v
vlog -work work ../rtl/decode.v
vlog -work work ../rtl/piso_reg.v
vlog -work work ../rtl/sipo_reg.v
vlog -work work ../rtl/serdes_tx.v
vlog -work work ../rtl/serdes_rx.v

# Compila arquivos de simulação
vlog -work work ../sim/tb_serdes.v
# test_8b10b.v é opcional, mas vamos garantir que compila também
vlog -work work ../sim/test_8b10b.v

echo "Compilação Concluída."
