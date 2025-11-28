# vlog Latch_SR_NOR_AND.v tb_Latch_SR_NOR_AND.v

vlog -work work ../latch_d_nand.v
vlog -work work ../tb_latch_d_nand.v


vsim -voptargs=+acc work.tb_latch_d_nand
add wave -r /*
run -all
