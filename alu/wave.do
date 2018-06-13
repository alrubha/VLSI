onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal -radix hexadecimal /alu/in_a
add wave -noupdate -format Literal -radix hexadecimal /alu/in_b
add wave -noupdate -format Literal -radix hexadecimal /alu/opcode
add wave -noupdate -format Literal -radix hexadecimal /alu/alu_out
add wave -noupdate -format Logic -radix hexadecimal /alu/alu_zero
add wave -noupdate -format Logic -radix hexadecimal /alu/alu_carry
add wave -noupdate -format Literal -radix hexadecimal /alu/alu_out_int
add wave -noupdate -format Literal -radix hexadecimal /alu/in_a_int
add wave -noupdate -format Literal -radix hexadecimal /alu/in_b_int
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {0 ns} {119 ns}
