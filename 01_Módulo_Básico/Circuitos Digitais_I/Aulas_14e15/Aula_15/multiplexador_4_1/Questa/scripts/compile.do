# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work
if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/multiplexador_4_1.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/multiplexador_4_1.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/multiplexador_4_1.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}
vlog -work work ../tb/tb_multiplexador_4_1.v
