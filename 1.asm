;Olvasson be két darab bájtos értéket, adja össze azokat, majd az eredményt irja ki a képemyöre.


.MODEL SMALL
.STACK
.CODE

main proc ;Főprogram
CALL read_decimal ;Decimális szám beolvasása
MOV AL, DL ;AL be eltarolja a DL értéket
CALL read_decimal ;Decimális szám beolvasása
ADD AL, DL ; AL ben van az összeg eltarolva
MOV DL, AL ; DL be mozgatjuk az összeget AL ből
CALL write_decimal ; kiiratas subrutin meghivasa
MOV AH,4Ch ;Kilépés
INT 21h
main endp

CR EQU 13

;decimális beolvasás

read_decimal proc
PUSH AX ;AX mentése a verembe
PUSH BX ;BX mentése a verembe
MOV BL, 10 ;BX-be a számrendszer alapszáma, ezzel szorzunk
XOR AX, AX ;AX törlése
read_decimal_new:
CALL read_char ;Egy karakter beolvasása
CMP DL, CR ;ENTER ellenőrzése
JE read_decimal_end ;Vége, ha ENTER volt az utolsó karakter
SUB DL, "0" ;Karakterkód minusz ”0” kódja
MUL BL ;AX szorzása 10-zel
ADD AL, DL ;A következő helyi érték hozzáadása
JMP read_decimal_new ;A következő karakter beolvasása
read_decimal_end:
MOV DL, AL ;DL-be a beírt szám
POP BX ;AB visszaállítása
POP AX ;AX visszaállítása
RET ;Visszatérés a hívó rutinba
read_decimal endp


;decimális kiírás

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

;hexadecimális kiírás

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


;karakter beolvasása

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

;karakter kiírása

write_char proc ;A DL-ben lévő karakter kiírása a képernyőre
PUSH AX ;AX mentése a verembe
MOV AH, 2 ; AH-ba a képernyőre írás funkciókódja
INT 21h ; Karakter kiírása
POP AX ;AX visszaállítása
RET ;Visszatérés a hívó rutinba
write_char endp
end main