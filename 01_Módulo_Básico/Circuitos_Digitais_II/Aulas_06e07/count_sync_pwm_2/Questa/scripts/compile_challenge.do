
# Arquivo: compile_challenge.do
# Compila os arquivos do desafio extra

if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

# Compilação dos módulos
vlog -work work ../rtl/behavioral/pwm_50hz_behav.v
vlog -work work ../rtl/behavioral/debounce.v
vlog -work work ../rtl/behavioral/seven_seg_driver.v
vlog -work work ../rtl/behavioral/top_pwm_challenge.v
vlog -work work ../tb/tb_top_pwm_challenge.v
