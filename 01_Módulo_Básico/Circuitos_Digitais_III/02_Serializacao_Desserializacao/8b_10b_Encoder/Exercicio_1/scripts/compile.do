# Arquivo: compile.do (Exercício 1)
vlib work
vmap work work

# Compila os arquivos locais da pasta Exercicio_1 (Caminhos relativos atualizados)
vlog -work work ../rtl/encode.v
vlog -work work ../rtl/decode.v
vlog -work work ../sim/test_8b10b.v

echo "Compilação do Exercício 1 Concluída."
