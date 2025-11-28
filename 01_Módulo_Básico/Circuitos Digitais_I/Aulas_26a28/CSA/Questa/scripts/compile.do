\
# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work
if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/csa.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/csa.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/csa.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}
vlog -work work ../tb/tb_csa.v
