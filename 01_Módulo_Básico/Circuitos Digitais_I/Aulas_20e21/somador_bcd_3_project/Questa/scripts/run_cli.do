# Executa em modo CLI (usa implementação selecionada em compile.do)
vsim -c -voptargs=+acc work.tb_somador_bcd_3 -do "run -all; quit -f"
