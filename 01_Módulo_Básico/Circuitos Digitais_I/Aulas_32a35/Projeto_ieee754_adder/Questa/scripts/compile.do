# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/ieee754_adder.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/ieee754_adder.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/ieee754_adder.v
} else {
    echo "IMPLEMENTATION inválido: $IMPLEMENTATION"
    return
}

vlog -work work ../tb/tb_ieee754_adder.v
