vcom -work work -O0 D:/My_DevOps/Spring_2023/EE316_Junior_Lab/EE316_Sine_Wave_PWM_LCD_I2C/src/Counter/counter/counter_tb.vhd
vcom -work work -O0 D:/My_DevOps/Spring_2023/EE316_Junior_Lab/EE316_Sine_Wave_PWM_LCD_I2C/src/Counter/counter/counter.vhd
vsim -voptargs=+acc work.counter_tb
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk /counter_tb/clk
add wave -noupdate -label ireset /counter_tb/ireset
add wave -noupdate -label carry_out /counter_tb/carry_out
add wave -noupdate -label direction /counter_tb/direction
add wave -noupdate -label count_out /counter_tb/count_out
add wave -noupdate -label out_size /counter_tb/count_out_size
add wave -noupdate -label clk_en /counter_tb/c/clk_en_count
add wave -noupdate -label en_signal /counter_tb/c/en
add wave -noupdate -label count_int_reg /counter_tb/c/count_int_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {62267 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1250 ns}
run 1200 ns