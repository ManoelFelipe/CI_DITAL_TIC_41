# =====================================================================
# Arquivo : clean.do
# Autor   : Manoel Furtado
# Data    : 15/11/2025
# Descricao: Script de limpeza robusto para Questa/ModelSim,
#            removendo biblioteca work e arquivos temporarios.
# Revisao : v1.0 — criacao inicial
# =====================================================================

catch {quit -sim}
catch {dataset close -all}
catch {wave clear}
catch {transcript off}
catch {transcript file ""}

if {[file exists work]} { catch {vdel -lib work -all} }
catch {vlib work}
catch {vmap work work}

proc safe_delete {path} {
    if {[file exists $path]} {
        if {[catch {file delete -force $path} err]} {
            puts "WARN: nao foi possivel deletar '$path' — $err (continuando)."
        }
    }
}

foreach f {transcript vsim.wlf wave.vcd vsim.dbg wlft3.wlf vsim.dbg/mdb.log} {
    safe_delete $f
}
