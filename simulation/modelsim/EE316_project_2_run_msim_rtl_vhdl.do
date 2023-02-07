transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {D:/My_DevOps/Spring_2023/EE316_Junior_Lab/EE316_Sine_Wave_PWM_LCD_I2C/src/Counter/decimal_counter.vhd}
vcom -93 -work work {D:/My_DevOps/Spring_2023/EE316_Junior_Lab/EE316_Sine_Wave_PWM_LCD_I2C/src/Counter/counter/counter.vhd}

