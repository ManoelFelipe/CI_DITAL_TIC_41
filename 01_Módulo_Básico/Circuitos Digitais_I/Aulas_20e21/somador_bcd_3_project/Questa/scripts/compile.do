# compile.do — behavioral | dataflow | structural | all
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/somador_bcd_3.v +define+IMPL_BEHAV
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/somador_bcd_3.v   +define+IMPL_DATAFLOW
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/somador_bcd_3.v +define+IMPL_STRUCT
} elseif {$IMPLEMENTATION eq "all"} {
    vlog -work work ../rtl/behavioral/somador_bcd_3.v
    vlog -work work ../rtl/dataflow/somador_bcd_3.v
    vlog -work work ../rtl/structural/somador_bcd_3.v +define+IMPL_ALL
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}
vlog -work work ../tb/tb_somador_bcd_3.v
