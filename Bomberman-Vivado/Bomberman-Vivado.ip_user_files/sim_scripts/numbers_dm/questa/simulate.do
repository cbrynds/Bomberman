onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib numbers_dm_opt

do {wave.do}

view wave
view structure
view signals

do {numbers_dm.udo}

run -all

quit -force
