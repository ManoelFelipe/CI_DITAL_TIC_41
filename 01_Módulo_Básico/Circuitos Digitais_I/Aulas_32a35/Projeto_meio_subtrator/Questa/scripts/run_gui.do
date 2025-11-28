# ---------------- run_gui.do ----------------
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_meio_subtrator
add wave -r /*
run -all
