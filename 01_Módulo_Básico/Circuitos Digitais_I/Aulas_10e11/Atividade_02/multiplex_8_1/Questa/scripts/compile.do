# compile.do — selecione o estilo: behavioral | dataflow | structural
quietly set IMPLEMENTATION structural
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work
if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/multiplex_8_1.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/multiplex_8_1.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/multiplex_8_1.v
} else {
    echo "IMPLEMENTATION inválido: $IMPLEMENTATION"
    return
}
vlog -work work ../tb/tb_multiplex_8_1.v
