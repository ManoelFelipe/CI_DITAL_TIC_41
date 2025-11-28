\
    # Limpeza segura (Questa/ModelSim Intel)
    # clean.do — robusto / idempotente
    # Fecha qualquer simulação e libera o handle do vsim.wlf
    catch {quit -sim}
    catch {dataset close -all}
    catch {wave clear}
    catch {transcript off}
    catch {transcript file ""}

    # Remove/zera a lib work com tolerância a erro
    if {[file exists work]} { catch {vdel -lib work -all} }
    catch {vlib work}
    catch {vmap work work}

    # Função utilitária: tenta deletar e não aborta se falhar
    proc safe_delete {path} {
        if {[file exists $path]} {
            if {[catch {file delete -force $path} err]} {
                puts "WARN: não foi possível deletar '$path' — $err (continuando)."
            }
        }
    }

    # Arquivos típicos gerados pelo Questa/ModelSim
    foreach f {transcript vsim.wlf wave.vcd vsim.dbg wlft3.wlf vsim.dbg/mdb.log} {
        safe_delete $f
    }
