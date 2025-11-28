\
# Limpeza segura (Questa/ModelSim Intel)
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work
foreach f {transcript vsim.wlf wave.vcd vsim.dbg wlft3.wlf} {
    if {[file exists $f]} { file delete -force $f }
}
