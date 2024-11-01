; estop.g - Configure software-based emergency stop

; NOTE: A software controlled emergency stop is NOT a replacement for
; a hardware emergency stop that cuts all power to the machine. If
; you use this method of emergency stop, you need to be aware that it
; likely does not meet the safety standards for industrial machinery,
; and you agree that you are using it at your own risk.

; Please use this IN ADDITION TO a hardware emergency stop -
; NOT AS A REPLACEMENT.

; Configure emergency stop input. You must set the C"..." parameter to
; the pin identifier where your emergency stop input is connected.
M950 J1 C"^PC_15"

; Fire trigger 0 (emergency stop) on status change
M581 P1 T2 S1 R0

; Check e-stop is not active before continuing startup
echo {"Checking E-Stop status..."}
M582 T2
echo {"E-Stop is not activated, continuing startup"}
