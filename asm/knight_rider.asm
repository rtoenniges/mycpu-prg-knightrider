;[ASCII]

;******************************************
;************* Knight Rider  **************
;******************************************
;*******  2015 by Robin Tönniges  *********
;******************************************

#include <sys.hsm>
#include <tsr.hsm>


;-------------------------------------;
; declare variables

KERN_IOCHANGELED    EQU 0306h


VAR_timerdiv     DB    3 ;Timer divison factor
VAR_timerhandle  DB    0
VAR_timerloops   DB    0
VAR_leds         DB    01h
VAR_direction    DB    0

;-------------------------------------;
; begin of assembly code

codestart
#include <tsr.hsm>

initfunc  

        ;move this program to a separate memory page
        LPT  #codestart
        LDA  #0Eh
        JSR  (KERN_MULTIPLEX)  ;may fail on older kernel
    
        LDAA VAR_timerdiv
        STAA VAR_timerloops
        LDAA VAR_leds
        JSR  (KERN_IOCHANGELED)
        
        ;Setup timer-interrupt
        CLA    
        LPT  #timercallback  
        JSR  (KERN_MULTIPLEX) 
        STAA VAR_timerhandle  ;Save adress of timerhandle
        CLA
        RTS

;Timer interrupt
timercallback
        DECA VAR_timerloops
        JPZ  start
        CLA
        RTS

start   LDAA VAR_timerdiv
        STAA VAR_timerloops
        LDAA VAR_leds
        CMP  #1
        JPZ  setl
        LDAA VAR_leds
        CMP  #8
        JNZ  checkdir

setr    LDA #1
        STAA VAR_direction
        JMP  checkdir           

setl    CLA
        STAA VAR_direction

checkdir  LDAA VAR_direction
          CMP  #0
          JNZ  right

left    SHLA VAR_leds
        LDAA VAR_leds
        JSR  (KERN_IOCHANGELED)
        RTS

right   SHRA VAR_leds
        LDAA VAR_leds
        JSR  (KERN_IOCHANGELED)
        RTS

_RTS    CLC
        RTS

termfunc  
        ;set leds to default
        LDA  #0FFh
        JSR  (KERN_IOCHANGELED)
        ;uninstall timer interrupt
        LDXA VAR_timerhandle
        JPZ  _RTS
        STZ  VAR_timerhandle
        LDA  #1
        JMP  (KERN_MULTIPLEX)
        RTS
