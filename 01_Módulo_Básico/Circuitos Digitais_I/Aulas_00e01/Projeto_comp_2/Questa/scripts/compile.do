# compile.do — behavioral | dataflow | structural

# Parâmetro selecionável para a implementação alvo
quietly set IMPLEMENTATION behavioral

# Prepara biblioteca de trabalho
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Seleciona qual versão do comparador será compilada
if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/comp_2.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/comp_2.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/comp_2.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

# Compila o testbench comum às três abordagens
vlog -work work ../tb/tb_comp_2.v
