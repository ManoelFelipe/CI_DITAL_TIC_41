\
    # Execução em modo console
    if {$argc >= 1} {
        quietly set IMPLEMENTATION [lindex $argv 0]
    } else {
        quietly set IMPLEMENTATION behavioral
    }

    do clean.do
    do compile.do
    vsim -c -voptargs=+acc work.tb_ULA_LSL_LSR_mod_3 -do "run -all; quit -f"
