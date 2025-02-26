; milojfk-config.g - Configure miloJFK specific parts

; Set machine name
M550 P"miloJFK"

; Use this to set calibrated steps-per-mm
M92 X797.7 Y797.65 Z1597.4

; Use this to set backlash compensation
;M425 X0.05 Y0.04 Z0.06 S10

; Configure thermistor in wire duct port 1
M308 S1 P"PA_3" Y"thermistor" A"WD Temperature" T100000 B4267 C0

; Configure fans
; Intake
M106 P0 S0.3 H-1

; Exhaust
M106 P1 T45 H1 X0.5

; Configure coolant port 0
M950 P0 C"PB_3"

; Turn on the Neopixel
M150 E0 R255 B255 P100 S100 F0

; Turn on the LED
M42 P1 S0.5
