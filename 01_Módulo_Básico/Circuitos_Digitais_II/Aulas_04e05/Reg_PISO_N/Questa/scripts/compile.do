# compile.do — behavioral | dataflow | structural

# Define default implementation if not set
if {![info exists IMPLEMENTATION]} {
    quietly set IMPLEMENTATION behavioral
}

puts "Compiling for implementation: $IMPLEMENTATION"

if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/reg_piso_n.v
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/reg_piso_n.v
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/reg_piso_n.v
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

vlog -work work ../tb/tb_reg_piso_n.v
