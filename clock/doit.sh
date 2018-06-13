#!/bin/bash 

vlog clock.sv
vsim -novopt -do clock.do clock
