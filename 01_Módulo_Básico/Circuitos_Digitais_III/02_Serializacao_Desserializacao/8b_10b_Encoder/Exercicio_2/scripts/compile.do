# Arquivo: compile.do (Exercício 2)
vlib work
vmap work work

# Compila arquivos RTL
vlog -work work ../rtl/encode.v
vlog -work work ../rtl/decode.v
vlog -work work ../rtl/piso_reg.v
vlog -work work ../rtl/sipo_reg.v
vlog -work work ../rtl/serdes_tx.v
vlog -work work ../rtl/serdes_rx.v

# Compila testbench do exercício 2
vlog -work work ../sim/tb_exercise2.v

echo "Compilação do Exercício 2 Concluída."
