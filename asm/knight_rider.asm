;[ASCII]

;******************************************
;************* Knight Rider  **************
;******************************************
;*******  2017 by Robin Tönniges  *********
;******************************************

#include <sys.hsm>
#include <tsr.hsm>

;Addresses
KERN_IOCHANGELED    EQU 0306h

;Parameter
PARAM_TIMERDIV      SET 4   ;Timer divison factor

;Variables
VAR_timerhandle     DB  0
VAR_timerdiv        DB  0
VAR_leds            DB  01h
VAR_direction       DB  0

;-------------------------------------;
; begin of assembly code

codestart
#include <tsr.hsm>

;--------------------------------------------------------- 
;TSR init 
;--------------------------------------------------------- 
initfunc  

            ;move this program to a separate memory page
            ;LPT  #codestart
            ;LDA  #0Eh
            ;JSR  (KERN_MULTIPLEX)  ;may fail on older kernel
    
            LDA  #PARAM_TIMERDIV
            STAA VAR_timerdiv
            LDAA VAR_leds
            JSR  (KERN_IOCHANGELED)
        
            ;Setup timer-interrupt
            CLA    
            LPT  #timercallback  
            JSR  (KERN_MULTIPLEX) 
            STAA VAR_timerhandle  ;Save adress of timerhandle
            CLA
            RTS

;--------------------------------------------------------- 
;Timer interrupt   
;--------------------------------------------------------- 
timercallback
            DECA VAR_timerdiv
            JPZ  start
            RTS

;--------------------------------------------------------- 
;Main program 
;--------------------------------------------------------- 
start   
            LDA  #PARAM_TIMERDIV
            STAA VAR_timerdiv
            
            LDAA VAR_leds
            CMP  #01h
            JPZ  setl
            CMP  #08h
            JNZ  checkdir

setr        LDA #01h
            STAA VAR_direction
            JMP  right           

setl        STZ VAR_direction
            JMP  left

checkdir    LDAA VAR_direction
            JNZ  right

left        SHLA VAR_leds
            LDAA VAR_leds
            JSR  (KERN_IOCHANGELED)
            RTS

right       SHRA VAR_leds
            LDAA VAR_leds
            JSR  (KERN_IOCHANGELED)
            RTS

_RTS        CLC
            RTS

;--------------------------------------------------------- 
;TSR termination
;--------------------------------------------------------- 
termfunc  
            ;set leds to default
            LDA  #FFh
            JSR  (KERN_IOCHANGELED)
            ;uninstall timer interrupt
            LDXA VAR_timerhandle
            JPZ  _RTS
            STZ  VAR_timerhandle
            LDA  #01h
            JMP  (KERN_MULTIPLEX)
            RTS
