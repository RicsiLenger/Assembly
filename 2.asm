;Olvasson be két bináris számot. végezze el az AND műveltet, majd az eredményt írja ki a képemnyőre.

.MODEL SMALL
.STACK
.CODE
main proc ;Főprogram

CALL cr_lf ; Soremelés
CALL read_binary ; Első bináris szám beolvasása, az eredmény DL-ben
MOV AL, DL ; Az első szám mentése AL-be

CALL cr_lf ; Soremelés
CALL read_binary ; Második bináris szám beolvasása, az eredmény DL-ben

AND AL, DL ; AND művelet az első és a második szám között

CALL cr_lf ; Soremelés
MOV DL, AL ; Az eredmény DL-be másolása a kiíráshoz
CALL write_binary ; Az eredmény kiírása bináris formában

MOV AH, 4Ch ; Kilépés
INT 21h

main endp

read_char proc 
PUSH AX
MOV AH, 1
INT 21h
MOV DL, AL
POP AX
RET
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

write_char proc
PUSH AX
MOV AH, 2
INT 21h
POP AX
RET
write_char endp

write_binary proc ;kiírandó adat a DL-ben
PUSH BX ;BX mentése a verembe
PUSH CX ;CX mentése a verembe
PUSH DX ;DX mentése a verembe
MOV BL, DL ;DL másolása BL-be
MOV CX, 8 ;Ciklusváltozó (CX) beállítása
binary_digit:
XOR DL, DL ;DL törlése
RCL BL, 1 ;Rotálás balra eggyel, kilépő bit a CF-be
ADC DL, "0" ;DL = DL + 48 + CF
CALL write_char ;Bináris digit kiírása
LOOP binary_digit ;Vissza a ciklus elejére
POP DX ;DX visszaállítása
POP CX ;CX visszaállítása
POP BX ;BX visszaállítása
RET ;Visszatérés a hívó rutinba
write_binary endp

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



END main