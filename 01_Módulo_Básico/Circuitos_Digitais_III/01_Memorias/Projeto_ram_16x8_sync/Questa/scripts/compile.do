# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/ram_16x8_sync.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/ram_16x8_sync.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/ram_16x8_sync.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

# Compila o testbench
vlog -work work ../tb/tb_ram_16x8_sync.v
