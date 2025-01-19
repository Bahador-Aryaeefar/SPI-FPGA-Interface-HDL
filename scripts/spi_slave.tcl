destroy .structure
destroy .wave
destroy .source
destroy .signal
# vdel -lib work -all

echo #########################################
echo 	"                                  "
echo 	" Simulation of the spi slave  ..."
echo 	"                                  "
echo #########################################

echo 	"Creating Library"

vlib work
vmap work

echo 	"Compiling spi slave modules..."
vlog -work work -quiet ../src/*.v
###-cover bcesx

echo 	"Compiling spi slave testbench..."
vlog -work work -quiet ../tb/test_spi_slave.v 

###-cover bcesx
vsim -voptargs=+acc -quiet -L work +no_tchk_msg +notimingchecks work.test_spi_slave

# Set simulation options (optional)
# This controls how many waves are displayed and how the simulation progresses
add wave -radix binary -position top /test_spi_slave/*

# Run the simulation for a specified time (e.g., 1000 ns)
run 5000ns
