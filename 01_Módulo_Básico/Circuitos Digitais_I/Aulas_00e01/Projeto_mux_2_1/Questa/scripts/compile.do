# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/mux_2_1.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/mux_2_1.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/mux_2_1.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

vlog -work work ../tb/tb_mux_2_1.v
