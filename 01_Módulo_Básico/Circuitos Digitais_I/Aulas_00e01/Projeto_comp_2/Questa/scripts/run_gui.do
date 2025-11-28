# run_gui.do — limpeza, compilação e simulação interativa

do clean.do
do compile.do

# Inicia simulação com acesso completo às hierarquias
vsim -voptargs=+acc work.tb_comp_2

# Adiciona todos os sinais do testbench na janela de ondas
add wave -r /*

# Executa simulação até o término definido no testbench
run -all
