;irja ki a képernyõre (egymás alá) a szám karaktereket.

.MODEL SMALL
.STACK
.CODE
main proc ;Főprogram

MOV CX, 10 ; Szám karakterek (0-9) száma
    MOV DL, '0' ; Kezdő karakter
print_loop:
    
    CALL write_char
    CALL cr_lf ; Soremelés
    INC DL ; Következő karakter
    LOOP print_loop ; Ciklus vissza

    MOV AH, 4Ch ; Kilépés
    INT 21h

MOV AH, 4Ch ; Kilépés
INT 21h
main endp

CR EQU 13 ;CR-be a kurzor a sor elejére kód
LF EQU 10 ;LF-be a kurzor új sorba kód

cr_lf proc
PUSH DX ;DX mentése a verembe
MOV DL, CR
CALL write_char ;kurzor a sor elejére
MOV DL, LF
CALL write_char ;Kurzor egy sorral lejjebb
POP DX ;DX visszaállítása
RET ;Visszatérés a hívó rutinba
cr_lf endp

write_char proc
PUSH AX
MOV AH, 2
INT 21h
POP AX
RET
write_char endp

END main