
# =============================================================
# run_gui.do - Execução em GUI (ModelSim/Questa)
# Uso: vsim -do scripts/run_gui.do
# =============================================================

do compile.do
vsim -voptargs=+acc work.tb_decodificador_4_16   ;# habilita visibilidade de sinais
add wave -r /*
run -all