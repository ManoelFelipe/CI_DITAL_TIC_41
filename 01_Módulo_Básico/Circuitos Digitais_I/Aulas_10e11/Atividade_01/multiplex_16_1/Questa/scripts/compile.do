# -----------------------------------------------------------------------------
# compile.do - Compile UM estilo de RTL + testbench para o mux 16x1
# Opções: behavioral | dataflow | structural
# -----------------------------------------------------------------------------
quietly set IMPLEMENTATION behavioral

# (Re)cria biblioteca
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Compila RTL escolhido
if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/multiplex_16_1.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/multiplex_16_1.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/multiplex_16_1.v
} else {
    echo "IMPLEMENTATION inválido: $IMPLEMENTATION"
    return
}

# Compila TB
vlog -work work ../tb/tb_multiplex_16_1.v
