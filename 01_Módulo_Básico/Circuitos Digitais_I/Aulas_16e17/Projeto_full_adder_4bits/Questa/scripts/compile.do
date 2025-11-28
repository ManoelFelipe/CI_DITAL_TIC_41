# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/full_adder_4bits.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/full_adder_4bits.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/full_adder_4bits.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

vlog -work work ../tb/tb_full_adder_4bits.v
