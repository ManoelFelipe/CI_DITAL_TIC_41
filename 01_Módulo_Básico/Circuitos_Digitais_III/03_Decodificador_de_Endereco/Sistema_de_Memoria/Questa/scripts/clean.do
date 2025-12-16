# Limpeza segura (Questa/ModelSim Intel)
# clean.do — robusto / idempotente
catch {quit -sim}
catch {dataset close -all}
catch {wave clear}
catch {transcript off}
catch {transcript file ""}

# Remove lib antiga se existir (tentativa de limpeza)
if {[file exists work]} {
    catch {vmap -del work}
    catch {vdel -lib work -all}
    if {[file exists work]} {
        catch {exec cmd /c rmdir /s /q work}
    }
}

# Remove nova lib se existir
if {[file exists work_lib]} {
    catch {vmap -del work}
    catch {vdel -lib work_lib -all}
    if {[file exists work_lib]} {
        puts "WARN: Tentando exclusão forçada de 'work_lib'..."
        catch {exec cmd /c rmdir /s /q work_lib}
    }
}

# Cria a nova biblioteca
catch {vlib work_lib}
# Mapeia 'work' (nome lógico) para 'work_lib' (pasta física)
catch {vmap work work_lib}

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
