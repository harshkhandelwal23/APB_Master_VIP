vlog apb_master_package.sv
vopt work.top -o tb_opt +acc=arn
vsim -assertdebug -msgmode both work.tb_opt
add wave -r /intf/*

run -all
