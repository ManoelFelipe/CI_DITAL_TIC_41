# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work
if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/subtrator_4_cop_2.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/subtrator_4_cop_2.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/subtrator_4_cop_2.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}
vlog -work work ../tb/tb_subtrator_4_cop_2.v
