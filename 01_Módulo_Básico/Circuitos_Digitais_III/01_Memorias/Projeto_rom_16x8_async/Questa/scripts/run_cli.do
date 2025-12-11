do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_rom_16x8_async -do "run -all; quit -f"
