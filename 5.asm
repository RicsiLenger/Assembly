;İrja ki a képemyőre (egymás alá) a nagybetű karaktereket.

.MODEL SMALL
.STACK
.CODE
main proc ;Főprogram

CALL print_uppercase

MOV AH, 4Ch ; Kilépés
INT 21h

main endp

write_char proc
PUSH AX
MOV AH, 2
INT 21h
POP AX
RET
write_char endp

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

print_uppercase proc
    PUSH AX        ; AX mentése a verembe
    PUSH DX        ; DX mentése a verembe

    MOV AL, 'A'    ; AL-be az 'A' karakter kódja
print_loop:
    MOV DL, AL     ; DL-be az aktuális karakter
    CALL write_char ; Karakter kiírása a képernyőre
    CALL cr_lf     ; Soremelés (új sorba lépés)

    INC AL         ; Következő karakter
    CMP AL, 'Z'    ; Ellenőrzés: elértük-e a 'Z'-t
    JLE print_loop ; Ha még nem, folytatás a ciklussal

    POP DX         ; DX visszaállítása
    POP AX         ; AX visszaállítása
    RET            ; Visszatérés a hívó rutinba
print_uppercase endp

END main