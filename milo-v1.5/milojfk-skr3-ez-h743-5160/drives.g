; drives.g - Configures motor driver settings

; Physical drive 0 (X) goes forwards using default driver timings
M569 P0 S1

; Physical drive 1 (Y) goes forwards using default driver timings
M569 P1 S1

; Physical drive 2 (Z) goes forwards using default driver timings
M569 P2 S1

; Change default short filter bandwidth due to longer cables
M569.2 P0 R{0x09} V{0x1060A}
M569.2 P1 R{0x09} V{0x1060A}
M569.2 P2 R{0x09} V{0x1060A}

; Set non-standard sense resistors for the BTT 5160 drivers
M569.9 P0.0 R0.022
M569.9 P0.1 R0.022
M569.9 P0.2 R0.022

; Set drive mappings to relevant axes
M584 X0 Y1 Z2

; Configure microstepping, no interpolation.
; This is about as high as we can go without losing
; significant amounts of torque.
; This puts our positional accuracy around the 0.02-0.04mm range.
M350 X32 Y32 Z32

; Milo lead-screws are 8mm pitch, with 1.8 degree motors or 200 steps per revolution
; Z axis is geared 2-1

; Set steps per mm.
M92 X800 Y800 Z1600

; Set motor currents (mA)
M906 X2300 Y2300 Z1500

; Set standstill current reduction to 5%
M917 X5 Y5 Z5

; Enable motor idle current reduction after 30 seconds
M84 S30
