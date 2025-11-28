# Limpeza segura (Questa/ModelSim Intel)
# clean.do — robusto / idempotente
catch {quit -sim}
catch {dataset close -all}
catch {wave clear}
catch {transcript off}
catch {transcript file ""}

# Remove/zera a lib work com tolerância a erro
if {[file exists work]} { catch {vdel -lib work -all} }
catch {vlib work}
catch {vmap work work}

proc safe_delete {path} {
    if {[file exists $path]} {
        if {[catch {file delete -force $path} err]} {
            puts "WARN: não foi possível deletar '$path' — $err (continuando)."
        }
    }
}

foreach f {transcript vsim.wlf wave.vcd vsim.dbg wlft3.wlf vsim.dbg/mdb.log} {
    safe_delete $f
}
