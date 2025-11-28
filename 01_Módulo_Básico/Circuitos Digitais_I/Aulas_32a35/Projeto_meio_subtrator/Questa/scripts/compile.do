# ---------------- compile.do ----------------
# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/meio_subtrator.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/meio_subtrator.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/meio_subtrator.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

vlog -work work ../tb/tb_meio_subtrator.v
