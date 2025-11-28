# compile.do — behavioral | dataflow | structural

quietly set IMPLEMENTATION behavioral

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if { $IMPLEMENTATION == "behavioral" } {
    vlog -work work ../rtl/behavioral/ula_datapath.v
} elseif { $IMPLEMENTATION == "dataflow" } {
    vlog -work work ../rtl/dataflow/ula_datapath.v
} elseif { $IMPLEMENTATION == "structural" } {
    vlog -work work ../rtl/structural/ula_datapath.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

vlog -work work ../tb/tb_ula_datapath.v
