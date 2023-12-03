if {[catch {

# define run engine funtion
source [file join {C:/lscc/radiant/2023.1} scripts tcl flow run_engine.tcl]
# define global variables
global para
set para(gui_mode) 1
set para(prj_dir) "Z:/es4/ES4-Final/collisions_and_rotations"
# synthesize IPs
# synthesize VMs
# propgate constraints
file delete -force -- collisions_and_rotations_impl_1_cpe.ldc
run_engine_newmsg cpe -f "collisions_and_rotations_impl_1.cprj" "mypll.cprj" -a "iCE40UP"  -o collisions_and_rotations_impl_1_cpe.ldc
# synthesize top design
file delete -force -- collisions_and_rotations_impl_1.vm collisions_and_rotations_impl_1.ldc
run_engine_newmsg synthesis -f "collisions_and_rotations_impl_1_lattice.synproj"
run_postsyn [list -a iCE40UP -p iCE40UP5K -t SG48 -sp High-Performance_1.2V -oc Industrial -top -w -o collisions_and_rotations_impl_1_syn.udb collisions_and_rotations_impl_1.vm] "Z:/es4/ES4-Final/collisions_and_rotations/impl_1/collisions_and_rotations_impl_1.ldc"

} out]} {
   runtime_log $out
   exit 1
}
