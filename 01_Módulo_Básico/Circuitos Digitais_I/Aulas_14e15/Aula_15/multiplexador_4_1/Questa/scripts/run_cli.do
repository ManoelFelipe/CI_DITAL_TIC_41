# Execução em modo CLI (não força saída do Questa, apenas roda)
vsim -c -do "do compile.do; vsim -voptargs=+acc work.tb_multiplexador_4_1; run -all; quit -f"
