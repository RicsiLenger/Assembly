;Alakitsa át a Read_char szubrutint úgy, hogy az ESC (27 kód) leüttésére kilépjen a programból.

.MODEL SMALL
.STACK
.CODE
main proc ;Főprogram

CALL read_binary

MOV AH, 4Ch ; Kilépés
INT 21h

main endp

CR EQU 13 ;CR-be a kurzor a sor elejére kód

read_char proc ; Karakter beolvasása. A beolvasott karakter DL-be kerül
    PUSH AX       ; AX mentése a verembe
read_char_new:
    MOV AH, 1     ; AH-ba a beolvasás funkciókód
    INT 21h       ; Egy karakter beolvasása, a kód AL-be kerül
    CMP AL, 27    ; Ellenőrzés: ha a karakter kódja 27 (ESC)
    JE exit_program ; Ha igen, ugrás a kilépéshez
    MOV DL, AL    ; DL-be a karakter kódja
    POP AX        ; AX visszaállítása
    RET           ; Visszatérés a hívó rutinba

exit_program:
    MOV AH, 4Ch   ; DOS kilépési funkció
    INT 21h       ; Program befejezése

read_char endp

read_binary proc
PUSH AX ;AX mentése a verembe
XOR AX, AX ;AX törlése
read_binary_new:
CALL read_char ;Egy karakter beolvasása
CMP DL, CR ;ENTER ellenőrzése
JE read_binary_end ;Vége, ha ENTER volt az utolsó karakter
SUB DL, "0" ;Karakterkód minusz ”0” kódja
SAL AL, 1 ;Szorzás 2-vel, shift eggyel balra
ADD AL, DL ;A következő helyi érték hozzáadása
JMP read_binary_new ;A következő karakter beolvasása
read_binary_end:
MOV DL, AL ;DL-be a beírt szám
POP AX ;AX visszaállítása
RET ;Visszatérés a hívó rutinba
read_binary endp

END main