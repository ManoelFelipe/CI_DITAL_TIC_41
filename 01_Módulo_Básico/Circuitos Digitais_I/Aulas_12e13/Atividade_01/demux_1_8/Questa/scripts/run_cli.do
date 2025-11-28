# run_cli.do — modo console (batch). Permite escolher IMPLEMENTATION externamente.
# Ex.: vsim -c -do "quietly set IMPLEMENTATION dataflow; do run_cli.do"
do clean.do
if {![info exists IMPLEMENTATION]} { quietly set IMPLEMENTATION behavioral }
do compile.do
vsim -c -voptargs=+acc work.tb_demux_1_8 -do "run -all; quit -f"
