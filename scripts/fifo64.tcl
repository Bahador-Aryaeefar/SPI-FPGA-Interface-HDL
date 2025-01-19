destroy .structure
destroy .wave
destroy .source
destroy .signal
# vdel -lib work -all

echo #########################################
echo 	"                                  "
echo 	" Simulation of the fifo64  ..."
echo 	"                                  "
echo #########################################

echo 	"Creating Library"

vlib work

echo 	"Compiling fifo64 modules..."
vlog -work work -quiet ../src/*.v
###-cover bcesx

echo 	"Compiling fifo64 testbench..."
vlog -work work -quiet ../tb/test_fifo64.v 

###-cover bcesx
vsim -voptargs=+acc -quiet -L work +no_tchk_msg +notimingchecks work.test_fifo64

# Set simulation options (optional)
# This controls how many waves are displayed and how the simulation progresses
add wave -position top /test_fifo64/*

# Run the simulation for a specified time (e.g., 1000 ns)
run 5000ns
