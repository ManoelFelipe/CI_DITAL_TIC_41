# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/ULA_LSL_LSR.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/ULA_LSL_LSR.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/ULA_LSL_LSR.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

vlog -work work ../tb/tb_ULA_LSL_LSR.v
