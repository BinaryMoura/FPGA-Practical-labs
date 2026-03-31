// Timing constraints for servo_control project
// Tang Nano 9K - 27MHz clock

create_clock -name sys_clk -period 37.037 -waveform {0 18.518} [get_ports sys_clk]

// Clock uncertainty
set_clock_uncertainty -setup 0.5 [get_clocks sys_clk]
set_clock_uncertainty -hold 0.3 [get_clocks sys_clk]
