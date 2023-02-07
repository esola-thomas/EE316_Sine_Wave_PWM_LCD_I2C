onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk /decimal_counter_tb/clk
add wave -noupdate -label ireset /decimal_counter_tb/ireset
add wave -noupdate -label direction /decimal_counter_tb/direction
add wave -noupdate -label o_integer /decimal_counter_tb/i
add wave -noupdate -label o_decimal /decimal_counter_tb/d
add wave -noupdate -label int_reg /decimal_counter_tb/DUT/int_reg
add wave -noupdate -label deci_reg /decimal_counter_tb/DUT/deci_reg
add wave -noupdate -label int_count_out_(bit) -radix unsigned /decimal_counter_tb/DUT/int_count_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {188 ps} 0}
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
WaveRestoreZoom {1133757 ps} {4150855 ps}
