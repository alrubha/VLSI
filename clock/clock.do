add wave -position insertpoint sim:/clock/*
force -freeze sim:/clock/clk_1sec 1 0, 0 {5 ns} -r 10
force -freeze sim:/clock/clk_1ms 1 0, 0 {0 ns} -r 1
force reset_n 0
force mil_time 0
run 20
force reset_n 1
run 1036800
force mil_time 1
run 1036800
