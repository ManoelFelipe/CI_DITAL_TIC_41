
# Limpeza de artefatos típicos do ModelSim/Questa
quietly set dirs {work transcript vsim.wlf modelsim.ini wave.vcd}
vdel -all
foreach d $dirs {

    file delete -force $d
}
# quit -f


# file delete -force -- transcript vsim.wlf wave.vcd
