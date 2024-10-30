; fans.g - Configures fans

; Configure intake fan port 0 and enable at startup
M950 F0 C"PB_7" Q500
M106 P0 S0.3 H-1

; Configure exhaust fan port 1 and enable at startup
M950 F0 C"PB_6" Q500
M106 P0 S0.3 H-1
