transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/Users/schumae/Documents/EE316_Sine_Wave_PWM_LCD_I2C/src/System_State/system_state.vhd}
vcom -93 -work work {C:/Users/schumae/Documents/EE316_Sine_Wave_PWM_LCD_I2C/src/Counter/decimal_counter.vhd}
vcom -93 -work work {C:/Users/schumae/Documents/EE316_Sine_Wave_PWM_LCD_I2C/src/LCD/LCD_master.vhd}
vcom -93 -work work {C:/Users/schumae/Documents/EE316_Sine_Wave_PWM_LCD_I2C/src/LCD/LCD_user_logic.vhd}
vcom -93 -work work {C:/Users/schumae/Documents/EE316_Sine_Wave_PWM_LCD_I2C/src/Counter/counter/counter.vhd}

