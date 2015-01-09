onbreak resume
onerror resume
vsim -novopt work.filter_tb
add wave sim:/filter_tb/u_filtro_di_prova_under/clk
add wave sim:/filter_tb/u_filtro_di_prova_under/clk_enable
add wave sim:/filter_tb/u_filtro_di_prova_under/reset
add wave sim:/filter_tb/u_filtro_di_prova_under/filter_in
add wave sim:/filter_tb/u_filtro_di_prova_under/filter_out
add wave sim:/filter_tb/filter_out_ref
run -all
