# Executa a simulação no terminal (não encerra o vsim à força)
vsim -voptargs=+acc work.tb_decodificador_2_4 -c -do "run -all"
