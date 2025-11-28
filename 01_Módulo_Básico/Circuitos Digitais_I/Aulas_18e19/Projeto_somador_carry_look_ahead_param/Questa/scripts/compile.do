# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work
if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/somador_carry_look_ahead_param.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/somador_carry_look_ahead_param.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/somador_carry_look_ahead_param.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"; return
}
vlog -work work ../tb/tb_somador_carry_look_ahead_param.v
