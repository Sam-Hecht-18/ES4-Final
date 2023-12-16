#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology SBTICE40UP
set_option -part iCE40UP5K
set_option -package SG48I
set_option -speed_grade -6
#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog standard option
set_option -vlog_std v2001

#map options
set_option -frequency 200
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -retiming false; set_option -pipe true
set_option -force_gsr auto
set_option -compiler_compatible 0


set_option -default_enum_encoding default

#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 0
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0
set_option -vhdl2008 1

set_option -rw_check_on_ram 0


#-- set any command lines input by customer

set_option -dup false
set_option -disable_io_insertion false
add_file -constraint {collisions_and_rotations_impl_1_cpe.ldc}
add_file -verilog {C:/lscc/radiant/2023.1/ip/pmi/pmi_iCE40UP.v}
add_file -vhdl -lib pmi {C:/lscc/radiant/2023.1/ip/pmi/pmi_iCE40UP.vhd}
add_file -vhdl -lib "work" {Z:/es4/ES4-Final/collisions_and_rotations/source/impl_1/master.vhd}
add_file -vhdl -lib "work" {Z:/es4/ES4-Final/collisions_and_rotations/source/impl_1/nes_controller.vhd}
add_file -vhdl -lib "work" {Z:/es4/ES4-Final/collisions_and_rotations/source/impl_1/vga.vhd}
add_file -verilog -vlog_std v2001 {Z:/es4/ES4-Final/collisions_and_rotations/mypll/rtl/mypll.v}
add_file -vhdl -lib "work" {Z:/es4/ES4-Final/collisions_and_rotations/source/impl_1/collision_check.vhd}
add_file -vhdl -lib "work" {Z:/es4/ES4-Final/collisions_and_rotations/source/impl_1/game_logic.vhd}
add_file -vhdl -lib "work" {Z:/es4/ES4-Final/collisions_and_rotations/source/impl_1/piece_library.vhd}
add_file -vhdl -lib "work" {Z:/es4/ES4-Final/collisions_and_rotations/source/impl_1/renderer.vhd}
add_file -vhdl -lib "work" {Z:/es4/ES4-Final/collisions_and_rotations/source/impl_1/clock_manager.vhd}
add_file -vhdl -lib "work" {Z:/es4/ES4-Final/collisions_and_rotations/source/impl_1/game_over.vhd}
add_file -vhdl -lib "work" {Z:/es4/ES4-Final/collisions_and_rotations/source/impl_1/game_state.vhd}
add_file -vhdl -lib "work" {Z:/es4/ES4-Final/collisions_and_rotations/source/impl_1/welcome.vhd}
#-- top module name
set_option -top_module master
set_option -include_path {Z:/es4/ES4-Final/collisions_and_rotations}

#-- run Synplify with 'arrange HDL file'
project -run hdl_info_gen -fileorder
set_option -include_path {Z:/es4/ES4-Final/collisions_and_rotations/mypll}

#-- set result format/file last
project -result_format "vm"
project -result_file {Z:/es4/ES4-Final/collisions_and_rotations/impl_1/collisions_and_rotations_impl_1.vm}

#-- error message log file
project -log_file {collisions_and_rotations_impl_1.srf}
project -run -clean
