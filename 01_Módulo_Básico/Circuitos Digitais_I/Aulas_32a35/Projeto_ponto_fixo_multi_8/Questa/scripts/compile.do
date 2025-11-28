# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/ponto_fixo_multi_8.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/ponto_fixo_multi_8.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/ponto_fixo_multi_8.v
} else {
    echo "IMPLEMENTATION inválido: $IMPLEMENTATION"
    return
}

vlog -work work ../tb/tb_ponto_fixo_multi_8.v
