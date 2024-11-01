; user-config.g - Configure machine or user-specific overrides PRE estop

; !!!WARNING!!!
; Do not energize any safety relevant systems

; Configure white LED port 1 and enable at startup
M950 P1 C"PD_7" Q500

; Configure Neopixel LED
M950 E0 C"PE_6" T1 U56
