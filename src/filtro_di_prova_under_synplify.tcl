project -new filtro_di_prova_under.prj
add_file filtro_di_prova_under.vhd
set_option -technology VIRTEX4
set_option -part XC4VSX35
set_option -synthesis_onoff_pragma 0
set_option -frequency auto
project -run synthesis
