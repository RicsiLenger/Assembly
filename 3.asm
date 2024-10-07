;Alakitsa át a Read_hexa szubrutint úgy, hogy csak a tizenhatos számrendszemek megfelelő karaktereket fogadja el.

.MODEL SMALL
.STACK
.CODE
main proc ;Főprogram

CALL cr_lf
CALL read_hexa
MOV AL, DL

CALL write_hexa
CALL cr_lf
CALL write_decimal

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

read_hexa proc
    PUSH AX              ; AX mentése a verembe
    PUSH BX              ; BX mentése a verembe
    MOV BL, 10h          ; BX-be a számrendszer alapszáma (16)
    XOR AX, AX           ; AX törlése (AX = 0)

read_hexa_new:
    CALL read_char       ; Egy karakter beolvasása
    CMP DL, CR           ; ENTER ellenőrzése
    JE read_hexa_end     ; Vége, ha ENTER volt az utolsó karakter
    CALL upcase          ; Kisbetű átalakítása naggyá

    ; Ellenőrizzük, hogy a DL regiszter tartalma számjegy (0-9) vagy betű (A-F)
    CMP DL, '0'          ; DL >= '0'?
    JL read_hexa_new     ; Ha kisebb mint '0', újraolvassuk a karaktert
    CMP DL, '9'          ; DL <= '9'?
    JBE read_hexa_decimal ; Ha számjegy (0-9), folytatás

    CMP DL, 'A'          ; DL >= 'A'?
    JL read_hexa_new     ; Ha kisebb mint 'A', újraolvassuk a karaktert
    CMP DL, 'F'          ; DL <= 'F'?
    JBE read_hexa_hex    ; Ha betű (A-F), folytatás
    JMP read_hexa_new    ; Ha nem szám vagy betű, újraolvassuk a karaktert

read_hexa_decimal:       ; Decimális számjegy (0-9)
    SUB DL, '0'          ; Karakterkód mínusz '0' kódja
    JMP read_hexa_process

read_hexa_hex:           ; Hexadecimális betű (A-F)
    SUB DL, 'A'          ; Karakterkód mínusz 'A' kódja
    ADD DL, 10           ; Betűk esetén 10-15 közötti értéket adunk

read_hexa_process:
    ; A szorzás előtt győződjünk meg, hogy az eredmény AX-ben marad
    MOV AH, 0            ; Győződj meg, hogy AH üres, hogy a szorzás ne okozzon problémát
    MUL BL               ; AX szorzása az alappal (16), az eredmény AX-be kerül
    ADD AX, DX           ; A következő helyi érték hozzáadása (AX-hez, nem csak AL-hez)
    JMP read_hexa_new    ; A következő karakter beolvasása

read_hexa_end:
    MOV DL, AL           ; DL-be a beírt szám alsó bájtja (csak AL-t adjuk vissza, ha 8 bit kell)
    POP BX               ; BX visszaállítása
    POP AX               ; AX visszaállítása
    RET
read_hexa endp

read_char proc ;Karakter beolvasása. A beolvasott karakter DL-be kerül
PUSH AX ;AX mentése a verembe
MOV AH, 1 ;AH-ba a beolvasás funkciókód
INT 21h ;Egy karakter beolvasása, a kód AL-be kerül
CMP AL, 27
JE escape
MOV DL, AL ;DL-be a karakter kódja
POP AX ;AX visszaállítása
RET ;Visszatérés a hívó rutinba
escape:
MOV AH,4Ch ;Kilépés
INT 21h
read_char endp

write_char proc ;A DL-ben lévő karakter kiírása a képernyőre
PUSH AX ;AX mentése a verembe
MOV AH, 2 ; AH-ba a képernyőre írás funkciókódja
INT 21h ; Karakter kiírása
POP AX ;AX visszaállítása
RET ;Visszatérés a hívó rutinba
write_char endp


write_hexa proc ;A DL-ben lévő két hexa számjegy kiírása
PUSH CX ;CX mentése a verembe
PUSH DX ;DX mentése a verembe
MOV DH, DL ;DL mentésebe
MOV CL, 4 ;Shift-elés száma CX-
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

upcase proc ;DL-ben lévő kisbetű átalakítása nagybetűvé
CMP DL, "a" ;A karakterkód és ”a” kódjának összehasonlítása
JB upcase_end ;A kód kisebb, mint ”a”, nem kisbetű
CMP DL, "z" ;A karakterkód és ”z” kódjának összehasonlítása
JA upcase_end ;A kód nagyobb, mint ”z”, nem kisbetű
SUB DL, "a"-"A" ;DL-ből a kódok különbségét
upcase_end:
RET ;Visszatérés a hívó rutinba
upcase endp

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

END main