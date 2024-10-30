; toolsetter.g - Configures the toolsetter

; === USAGE ===
; This is an example file, as your machine configuration does not
; include this functionality by default. To use this file, edit
; it using the instructions below, remove ".example" from the end
; of the filename, and restart your mainboard.
; === USAGE ===

; P8       - Unfiltered switch
; C"<pin>" - Input pin
; H5       - Dive height (height for repeated probes)
; A5       - Max number of probes
; S0.01    - Required tolerance
; T1200    - Travel speed, mm/min
; F600:300 - Probe Speed rough / fine, mm/min

; Configure toolsetter. You must set the C"..." parameter to
; the pin identifier where your toolsetter input is connected.
M558 K1 P8 C"<pin>" H5 A5 S0.01 T1200 F600:300