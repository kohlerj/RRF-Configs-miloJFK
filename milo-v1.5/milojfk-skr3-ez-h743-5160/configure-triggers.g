; estop.g - Configure software-based emergency stop

; NOTE: A software controlled emergency stop is NOT a replacement for
; a hardware emergency stop that cuts all power to the machine. If
; you use this method of emergency stop, you need to be aware that it
; likely does not meet the safety standards for industrial machinery,
; and you agree that you are using it at your own risk.

; Please use this IN ADDITION TO a hardware emergency stop -
; NOT AS A REPLACEMENT.

; Configure ESTOP pin trigger and set to fire trigger 3 (emergency stop) on status change
M950 J1 C"^PC_15"
;M581 P1 T3 S1 R0

; Check e-stop is not active before continuing startup
echo {"Checking E-Stop status..."}
M582 T3
echo {"E-Stop is not activated, continuing startup"}

; Configure RESET pin trigger and set to fire trigger 4 on reset
M950 J2 C"PC_13"
;M581 P2 T4 S0 R0

; Configure POWER pin trigger and set to fire trigger 2 on reset, takes precedence on emergency!
M950 J3 C"^PE_4"
;M581 P3 T2 S1 R0
