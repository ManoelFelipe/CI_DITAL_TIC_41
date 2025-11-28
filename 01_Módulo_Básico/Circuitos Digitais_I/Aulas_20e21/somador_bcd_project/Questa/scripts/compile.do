# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work +define+HAS_BEHAVIORAL ../rtl/behavioral/somador_bcd.v
    vlog -work work +define+HAS_BEHAVIORAL ../tb/tb_somador_bcd.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work +define+HAS_DATAFLOW ../rtl/dataflow/somador_bcd.v
    vlog -work work +define+HAS_DATAFLOW ../tb/tb_somador_bcd.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work +define+HAS_STRUCTURAL ../rtl/structural/somador_bcd.v
    vlog -work work +define+HAS_STRUCTURAL ../tb/tb_somador_bcd.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}
