# run_gui.do
do clean.do

# Nota: O compile.do original estava condicionado a uma variável.
# Para testar TUDO junto como pede o enunciado (instanciar as 3 DUTs no TB),
# precisamos garantir que os 3 modelos sejam compilados.
# Vamos substituir o comportamento padrão para compilar todos.

vlog -work work ../rtl/behavioral/ram_16x8_sync.v
vlog -work work ../rtl/dataflow/ram_16x8_sync.v
vlog -work work ../rtl/structural/ram_16x8_sync.v
vlog -work work ../tb/tb_ram_16x8_sync.v

vsim -voptargs="+acc" work.tb_ram_16x8_sync
add wave -r /*
run -all
