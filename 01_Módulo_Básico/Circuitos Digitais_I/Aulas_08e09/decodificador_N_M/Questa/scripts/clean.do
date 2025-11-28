# Limpeza segura (compatível com Questa Intel/ModelSim)
# Não precisamos apagar o modelsim.ini; deixe o vmap cuidar disso.

# Remove a lib 'work' se existir
if {[file exists work]} {
    vdel -lib work -all
}

# Cria e mapeia a lib 'work'
vlib work
vmap work work

# Remove artefatos de simulação (se existirem)
foreach f {transcript vsim.wlf wave.vcd vsim.dbg wlft3.wlf} {
    if {[file exists $f]} { file delete -force $f }
}