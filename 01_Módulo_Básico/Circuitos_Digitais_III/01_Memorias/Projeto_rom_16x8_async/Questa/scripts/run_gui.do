do clean.do
do compile.do
vsim -voptargs=+acc work.tb_rom_16x8_async
add wave -r /*
run -all
