# vlog Latch_SR_NOR_AND.v tb_Latch_SR_NOR_AND.v

vlog -work work ../Latch_SR_NORv
vlog -work work ../tb_Latch_SR_NOR.v


vsim -voptargs=+acc work.tb_Latch_SR_NOR
add wave -r /*
run -all



vsim tb_Latch_SR_NOR
add wave *
run -all