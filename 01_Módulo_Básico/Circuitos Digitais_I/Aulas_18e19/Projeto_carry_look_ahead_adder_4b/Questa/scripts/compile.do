
# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/carry_look_ahead_adder_4b.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/carry_look_ahead_adder_4b.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/carry_look_ahead_adder_4b.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

vlog -work work ../tb/tb_carry_look_ahead_adder_4b.v


#vlog -work work ../rtl/behavioral/bcarry_look_ahead_adder_4b.v
#vlog -work work ../rtl/structural/carry_look_ahead_adder_4b.v
#vlog -work work ../rtl/dataflow/carry_look_ahead_adder_4b.v
#vlog -work work ../tb/tb_carry_look_ahead_adder_4b.v
    