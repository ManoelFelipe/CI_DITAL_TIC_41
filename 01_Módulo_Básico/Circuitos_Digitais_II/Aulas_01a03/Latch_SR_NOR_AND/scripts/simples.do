# vlog Latch_SR_NOR_AND.v tb_Latch_SR_NOR_AND.v

vlog -work work ../Latch_SR_NOR_AND.v
vlog -work work ../tb_Latch_SR_NOR_AND.v


vsim -voptargs=+acc work.tb_Latch_SR_NOR_AND
add wave -r /*
run -all



vsim tb_Latch_SR_NOR_AND
add wave *
run -all