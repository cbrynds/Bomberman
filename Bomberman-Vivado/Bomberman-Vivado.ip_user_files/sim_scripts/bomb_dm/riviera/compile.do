vlib work
vlib riviera

vlib riviera/xil_defaultlib
vlib riviera/xpm
vlib riviera/dist_mem_gen_v8_0_12

vmap xil_defaultlib riviera/xil_defaultlib
vmap xpm riviera/xpm
vmap dist_mem_gen_v8_0_12 riviera/dist_mem_gen_v8_0_12

vlog -work xil_defaultlib  -sv2k12 \
"C:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2017.4/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work dist_mem_gen_v8_0_12  -v2k5 \
"../../../ipstatic/simulation/dist_mem_gen_v8_0.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../Bomberman-Vivado.srcs/sources_1/ip/bomb_dm/sim/bomb_dm.v" \


vlog -work xil_defaultlib \
"glbl.v"

