# compile.do — behavioral | dataflow | structural (compila todos DUTs necessários)
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Compila RTL de acordo com a árvore e também inclui as variantes necessárias
if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/half_adder.v
    vlog -work work ../rtl/behavioral/half_adder_alt.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/half_adder.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/half_adder.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

# O TB sempre requer todas as implementações para comparar
# Portanto, compile também as demais (garante que todos os módulos existam).
vlog -work work ../rtl/dataflow/half_adder.v
vlog -work work ../rtl/structural/half_adder.v

# Testbench
vlog -work work ../tb/tb_half_adder.v
