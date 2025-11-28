
# =============================================================
# run_gui.do - Limpa, compila e executa em GUI
# Uso: do scripts/run_gui.do
# =============================================================
# Limpeza simples
file delete -force work
vlib work
vmap work work

# Compilação (mesmo que compile.do)
vlog ../rtl/behavioral/decodificador_4_16.v
vlog ../rtl/dataflow/decodificador_4_16.v
vlog ../rtl/structural/decodificador_4_16.v
vlog ../tb/tb_decodificador_4_16.v

# Simulação em GUI
# vsim work.tb_decodificador_4_16
vsim -voptargs=+acc work.tb_decodificador_4_16   ;# habilita visibilidade de sinais
add wave -r /*
run -all
