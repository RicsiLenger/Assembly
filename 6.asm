;İrja ki a képemyõre (egymás alá) a szám karakterek ASCII kódját

.MODEL SMALL
.STACK
.CODE
main proc ;Főprogram

MOV CX, 10 ; Szám karakterek (0-9) száma
    MOV DL, '0' ; Kezdő karakter
print_loop:

    CALL write_decimal ; Kiírás decimális kód
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

write_decimal proc
PUSH AX ;AX mentése a verembe
PUSH CX ;CX mentése a verembe
PUSH DX ;DX mentése a verembe
PUSH SI ;SI mentése a verembe
XOR DH, DH ;DH törlése
MOV AX, DX ;AX-be a szám
MOV SI, 10 ;SI-ba az osztó
XOR CX, CX ;CX-be kerül az osztások száma
decimal_non_zero:
XOR DX, DX ;DX törlése
DIV SI ;DX:AX 32 bites szám osztása SI-vel, az eredmény AXbe, a maradék DX-be kerül
PUSH DX ;DX mentése a verembe
INC CX ;Számláló növelése
OR AX, AX ;Státuszbitek beállítása AX-nek megfelelően
JNE decimal_non_zero ;Vissza, ha az eredmény még nem nulla
decimal_loop:
POP DX ;Az elmentett maradék visszahívása
CALL write_hexa_digit ;Egy decimális digit kiírása
LOOP decimal_loop
POP SI ;SI visszaállítása
POP DX ;DX visszaállítása
POP CX ;CX visszaállítása
POP AX ;AX visszaállítása
RET ;Visszatérés a hívó rutinba
write_decimal endp

write_hexa proc ;A DL-ben lévő két hexa számjegy kiírása
PUSH CX ;CX mentése a verembe
PUSH DX ;DX mentése a verembe
MOV DH, DL ;DL mentése
MOV CL, 4 ;Shift-elés száma CX-be
SHR DL, CL ;DL shift-elése 4 hellyel jobbra
CALL write_hexa_digit ;Hexadecimális digit kiírása
MOV DL, DH ;Az eredeti érték visszatöltése DL-be
AND DL, 0Fh ;A felső négy bit törlése
CALL write_hexa_digit ;Hexadecimális digit kiírása
POP DX ;DX visszaállítása
POP CX ;CX visszaállítása
RET ;Visszatérés a hívó rutinba
write_hexa endp 

write_hexa_digit proc
PUSH DX ;DX mentése a verembe
CMP DL, 10 ;DL összehasonlítása 10-zel
JB non_hexa_letter ;Ugrás, ha kisebb 10-nél
ADD DL, "A"-"0"-10 ;A – F betűt kell kiírni
non_hexa_letter:
ADD DL, "0" ;Az ASCII kód megadása
CALL write_char ;A karakter kiírása
POP DX ;DX visszaállítása
RET ;Visszatérés a hívó rutinba
write_hexa_digit endp

END main