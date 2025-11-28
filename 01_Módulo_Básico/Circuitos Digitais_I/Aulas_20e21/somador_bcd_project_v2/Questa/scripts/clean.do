
# clean.do — segura contra locks
if {[string match "Running" [runStatus]]} {
    echo "Finalizando simulação anterior..."
    quit -sim
}
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work
foreach f {transcript vsim.wlf wave.vcd vsim.dbg wlft3.wlf} {
    catch { file delete -force $f }
}
