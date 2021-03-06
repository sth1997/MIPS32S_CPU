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
create_project -in_memory -part xc7a100tfgg676-2L

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.cache/wt [current_project]
set_property parent.project_path /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.xpr [current_project]
set_property XPM_LIBRARIES XPM_MEMORY [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_mem /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/boot.data
read_verilog -library xil_defaultlib {
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/CONST.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/CPU_TOP.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/EX.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/EX2MEM.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/ID.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/ID_EX.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/IF2ID.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/IF_PC_Reg.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/MEM2WB.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/Reg_Dir.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/SEG7_LUT.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/SERIAL.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/async.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/cp0.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/ctrl.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/flash.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/mem.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/mmu.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/rom.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/sram.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/vga.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/vir2phy.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/wb_conmax/wb_conmax_defines.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/wb_conmax/wb_conmax_arb.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/wb_conmax/wb_conmax_master_if.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/wb_conmax/wb_conmax_msel.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/wb_conmax/wb_conmax_pri_dec.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/wb_conmax/wb_conmax_pri_enc.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/wb_conmax/wb_conmax_rf.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/wb_conmax/wb_conmax_slave_if.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/wb_conmax/wb_conmax_top.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/wishbone_bus.v
  /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/thinpad_top.v
}
read_vhdl -library xil_defaultlib /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/new/Font_Rom.vhd
read_ip -quiet /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/ip/video_char_mem/video_char_mem.xci
set_property used_in_implementation false [get_files -all /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/sources_1/ip/video_char_mem/video_char_mem_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/constrs_1/new/thinpad_top.xdc
set_property used_in_implementation false [get_files /home/chenqiuhao/MIPS32S_CPU/thinpad_top/thinpad_top.srcs/constrs_1/new/thinpad_top.xdc]


synth_design -top thinpad_top -part xc7a100tfgg676-2L


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef thinpad_top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file thinpad_top_utilization_synth.rpt -pb thinpad_top_utilization_synth.pb"
