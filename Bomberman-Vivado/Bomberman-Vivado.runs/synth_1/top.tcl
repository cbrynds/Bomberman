# 
# Synthesis run script generated by Vivado
# 

proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param xicom.use_bs_reader 1
create_project -in_memory -part xc7a35tcpg236-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir E:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.cache/wt [current_project]
set_property parent.project_path E:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.xpr [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo e:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files E:/Bomberman/graphics/pillar.coe
add_files E:/Bomberman/graphics/bomberman_sprites_10.coe
add_files E:/Bomberman/graphics/block_map.coe
add_files E:/Bomberman/graphics/block.coe
add_files E:/Bomberman/graphics/bomb.coe
add_files E:/Bomberman/graphics/explosions.coe
add_files E:/Bomberman/graphics/enemy_sprites.coe
add_files {{E:/EEL5722-Projects/Lab 4  Display PS 2 Keyboard Input on a VGA Monitor/Numbers.coe}}
read_verilog -library xil_defaultlib {
  E:/Bomberman/Modules/LFSR.v
  E:/Bomberman/Modules/binary_to_bcd_converter.v
  E:/Bomberman/Modules/block_module.v
  E:/Bomberman/Modules/bomb_module.v
  E:/Bomberman/Modules/bomberman_module.v
  E:/Bomberman/Modules/debounce_button.v
  E:/Bomberman/Modules/enemy_module.v
  E:/Bomberman/Modules/game_lives.v
  E:/Bomberman/Modules/numbers_rom.v
  E:/Bomberman/Modules/pillar_display.v
  E:/Bomberman/Modules/score_display.v
  E:/Bomberman/Modules/vga_sync.v
  E:/Bomberman/Modules/top.v
}
read_ip -quiet E:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/pillar_dm/pillar_dm.xci
set_property used_in_implementation false [get_files -all e:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/pillar_dm/pillar_dm_ooc.xdc]

read_ip -quiet E:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/bm_sprite_br/bm_sprite_br.xci
set_property used_in_implementation false [get_files -all e:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/bm_sprite_br/bm_sprite_br_ooc.xdc]

read_ip -quiet E:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/block_map/block_map.xci
set_property used_in_implementation false [get_files -all e:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/block_map/block_map_ooc.xdc]

read_ip -quiet E:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/block_dm/block_dm.xci
set_property used_in_implementation false [get_files -all e:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/block_dm/block_dm_ooc.xdc]

read_ip -quiet E:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/bomb_dm/bomb_dm.xci
set_property used_in_implementation false [get_files -all e:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/bomb_dm/bomb_dm_ooc.xdc]

read_ip -quiet E:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/explosions_br/explosions_br.xci
set_property used_in_implementation false [get_files -all e:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/explosions_br/explosions_br_ooc.xdc]

read_ip -quiet E:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/enemy_sprite_br/enemy_sprite_br.xci
set_property used_in_implementation false [get_files -all e:/Bomberman/Bomberman-Vivado/Bomberman-Vivado.srcs/sources_1/ip/enemy_sprite_br/enemy_sprite_br_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc E:/Bomberman/bomberman_constraints.xdc
set_property used_in_implementation false [get_files E:/Bomberman/bomberman_constraints.xdc]


synth_design -top top -part xc7a35tcpg236-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_utilization_synth.rpt -pb top_utilization_synth.pb"
