# compile.do — compila as três abordagens do PWM e o testbench
if {[file exists work]} { catch {vdel -lib work -all} }
vlib work
vmap work work

# Arquivos RTL das três implementações
vlog -work work ../rtl/behavioral/pwm_50hz_behav.v
vlog -work work ../rtl/dataflow/pwm_50hz_data.v
vlog -work work ../rtl/structural/pwm_50hz_struct.v

# Testbench unificado
vlog -work work ../tb/tb_pwm_50hz.v
