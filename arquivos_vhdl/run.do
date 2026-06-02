vlib work
vcom -2019 -dbg rom_32x32.vhd ram_32x32.vhd ula.vhd control_unit.vhd design.vhd testbench.vhd

vsim +access+r work.tb_top

add wave /tb_top/clk
add wave /tb_top/reset
add wave /tb_top/start
add wave /tb_top/done
add wave -hex /tb_top/instruction
add wave /tb_top/DUT/U_FSM/state
add wave -uns /tb_top/DUT/rom_addr_s
add wave -uns /tb_top/DUT/rom_data_s
add wave -uns /tb_top/DUT/ula_a_s
add wave -uns /tb_top/DUT/ula_result_s
add wave /tb_top/DUT/ula_ovfl_s
add wave -uns /tb_top/DUT/ram_addr_s
add wave /tb_top/DUT/ram_we_s
add wave -uns /tb_top/DUT/ram_di_s

vcd file dump.vcd
vcd add -r /tb_top/*

run 1000ns
exit
