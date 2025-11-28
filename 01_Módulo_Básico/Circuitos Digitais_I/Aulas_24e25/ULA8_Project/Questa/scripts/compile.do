# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work
if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/ula_8.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/ula_8.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/ula_8.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}
vlog -work work ../tb/tb_ula_8.v
