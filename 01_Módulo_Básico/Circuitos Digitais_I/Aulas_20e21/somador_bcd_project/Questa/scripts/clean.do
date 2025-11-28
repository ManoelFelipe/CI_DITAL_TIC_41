
# clean.do — limpa simulação anterior sem erros de permissão

# Fecha simulação se ainda estiver ativa
if {[string match "Running" [runStatus]]} {
    echo "Finalizando simulação anterior..."
    quit -sim
}

# Remove diretório work
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

# Remove arquivos gerados (ignora erro de lock)
foreach f {transcript vsim.wlf wave.vcd vsim.dbg wlft3.wlf} {
    catch { file delete -force $f }
}