# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Selecione a implementação modificando a variável IMPLEMENTATION acima.
if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/wallace.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/wallace.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/wallace.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

vlog -work work ../tb/tb_wallace.v
