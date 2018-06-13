#!/bin/bash

if [ ! -d work ] 
	then
	vlib work
fi

if [ -s mult.sv ]
	then
	if [ -s mult_ctl.sv ]
		then
		vlog mult_ctl.sv
		vlog mult.sv
	else 
		vlog mult.sv
		mult_ctl.sv does not exist
	fi

fi

if [ -s mult.do ]
	then
	vsim -novopt -do mult.do mult -quiet -c -t 1ns -do quit 
fi

if [ -s syn_mult ]
	then
	design_vision-xg -f syn_mult
fi

verilog_file_dir=/nfs/guille/a1/cadlibs/synop_lib/SAED_EDK90nm/Digital_Standard_Cell_Library/verilog
echo "Compiling verilog source files in directory: $verilog_file_dir"
for verilog_source in `ls $verilog_file_dir`
do
vlog $verilog_file_dir/$verilog_source -work work
done

if [ -s mult.gate.v ]
	then
	vlog mult.gate.v
	vsim -novopt -do mult.do mult -quiet -c -t 1ns -do quit 
fi


