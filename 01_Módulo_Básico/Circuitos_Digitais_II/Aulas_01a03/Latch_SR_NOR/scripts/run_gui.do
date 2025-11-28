do clean.do
#do compile.do

vlog -work work ../Latch_SR_NOR.v
vlog -work work ../tb_Latch_SR_NOR.v

vsim -voptargs=+acc work.tb_Latch_SR_NOR
add wave -r /*
run -all
