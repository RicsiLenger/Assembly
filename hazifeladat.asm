.MODEL SMALL
Space = " "
CR = 13
.STACK
.DATA
    Kerdes1 DB "Kerem a meghajto szamat: ", 0
    Kerdes2 DB "Kerem a kiolvasando szektor szamat: ", 0
.DATA?
    drive DB 1 DUP(?)
    block DB 512 DUP (?) ;1 blokknyi terület kijelölése
    kar DB 1 DUP (?)
    y DB 1 DUP (?)
    x DB 1 DUP (?)
    attr DB 1 DUP (?)
.CODE

main proc
    ; Szegmensek beállítása
    CALL init_segments

    ; Felhasználói bemenet bekérése
    LEA BX, Kerdes1
    CALL get_user_input
    MOV drive, DL
    CALL new_line

    LEA BX, Kerdes2
    CALL get_user_input ; DX-ben lesz az olvasásig.

    ; Képernyő üzemmód beállítása
    CALL set_video_mode

    ; Blokk beolvasása a meghajtóról
    CALL read_disk_block

    ; Adatok kiírása és keretezés
    CALL write_block
    CALL paint_borders

    ; Program vége
    CALL exit_program
main endp

init_segments proc
    MOV AX, 0B800h ; Képernyő-memória szegmenscíme ES-be
    MOV ES, AX
    MOV AX, DGROUP ; DS beállítása
    MOV DS, AX
    RET
init_segments endp

get_user_input proc
    CALL write_string
    CALL read_decimal
    RET
get_user_input endp

set_video_mode proc
    MOV AH, 0h ; Képernyő üzemmód
    MOV AL, 3h ; 80x25-ös felbontás, színes üzemmód
    INT 10h
    RET
set_video_mode endp

read_disk_block proc
    LEA BX, block ; DS:BX memóriacímre tölti a blokkot
    MOV AL, drive ; Lemezmeghajtó száma (A:0, B:1, C:2, stb.)
    MOV CX, 1 ; Egyszerre beolvasott blokkok száma
    INT 13h ; Olvasás
    XOR DX, DX ; Kiírandó adatok kezdőcíme DS:DX
    RET
read_disk_block endp

paint_borders proc
    PUSH CX
    ;Külső keretek
    MOV CX, 67 ; Sorhossz

    ;Zöld keret
    MOV kar, " "
    MOV attr, 16*2

    MOV y, 1 ; Ahányadik sorba irja ki
    CALL paint_horizontal_borders
    MOV y, 25; Utolsó sora a 80*25-ös képernyőnek
    CALL paint_horizontal_borders

    MOV CX, 34 ; Oszlophossz
    MOV x, 1 ; Ahányadik oszlopba írja ki
    CALL paint_vertical_borders
    MOV x, 67 ;
    CALL paint_vertical_borders

    ;Belső oszlopelválasztás
    MOV x, 49
    CALL paint_vertical_borders
    MOV x, 50
    CALL paint_vertical_borders

    POP CX
paint_borders endp

paint_horizontal_borders proc
    PUSH DX
    PUSH CX

    MOV DL, 1
write_horizontal_border:
    MOV x, DL
    CALL write_screen
    INC DL
    LOOP write_horizontal_border

    POP CX
    POP DX
    RET
paint_horizontal_borders endp

paint_vertical_borders proc
    PUSH DX
    PUSH CX

    MOV DL, 1
write_vertical_border:
    MOV y, DL
    CALL write_screen
    INC DL
    LOOP write_vertical_border

    POP CX
    POP DX
    RET
paint_vertical_borders endp

write_block proc ;Egy blokk kiírása a képernyőre
    PUSH CX ;CX mentése
    PUSH DX ;DX mentése

    call new_line

    MOV CX, 32 ;Kiírandó sorok száma CX-be
write_block_new:
    CALL out_line ;Egy sor kiírása
    CALL new_line
    ADD DX, 16 ;Következő sor adatainak kezdőcíme;
    LOOP write_block_new ;Új sor
    POP DX ;DX visszaállítása
    POP CX ;CX visszaállítása
    RET
write_block endp

out_line proc
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, DX ;Sor adatainak kezdőcíme BX-be
    PUSH BX ;Mentés az ASCII karakteres kiíráshoz
    MOV CX, 16 ;Egy sorban 16 hexadecimális karakter

    ;1 karakternyi térköz a sorok elé
    MOV DL, " "
    CALL write_char
hexa_out:
    MOV DL, Block[BX] ;Egy bájt betöltése
    CALL write_hexa ;Kiírás hexadecimális formában
    MOV DL,Space ;Szóköz kiírása a hexa kódok között
    CALL write_char
    INC BX ;Következő adatbájt címe
    LOOP hexa_out ;Következő bájt
    MOV DL, Space ;Szóköz kiírása a kétféle mód között
    CALL write_char
    MOV CX, 16 ;Egy sorban 16 karakter
    POP BX ;Adatok kezdőcímének beállítása
ascii_out:
    MOV DL, Block[BX] ; Egy bájt betöltése
    CMP DL, Space ;Vezérlőkarakterek kiszűrése
    JA visible ;Ugrás, ha látható karakter
    MOV DL, Space ;Nem látható karakterek cseréje szóközre
visible:
    CALL write_char ;Karakter kiírása
    INC BX ;Következő adatbájt címe
    LOOP ascii_out ;Következő bájt
    POP DX ;DX visszaállítása
    POP CX ;CX visszaállítása
    POP BX ;BX visszaállítása
    RET ;Vissza a hívó programba
out_line endp

new_line proc
    PUSH DX

    ;Sor eleje (10-as parancs), kiírjuk hogy megtörténjen
    MOV DL, 10
    CALL write_char
    ;új sor (13-es parancs), kiírjuk hogy megtörténjen
    MOV DL, CR
    CALL write_char

    POP DX

    RET
new_line endp

write_char proc
    PUSH AX

    ;AH 2-es parancs az a kiírás, kiírja ami a DL-ben van (Data Low)
    MOV AH, 2
    INT 21h

    POP AX
    RET
write_char endp

write_hexa proc
    ;Mivel a D és a C regiszterekkel dolgozunk, mentjük őket a verembe, hogy megmaradjon bennük minden adat
    PUSH DX
    PUSH CX

    ;Itt a DH-ba mentjük a DL-t, valószínű azért mert itt minden művelet elvégezhető, de nincs itt ötlet.
    MOV DH, DL ; Mivel a DL-t shiftelni fogjuk mentjük DH-ba
    MOV CL, 4
    SHR DL, CL ;Shift Logical Right; SHR cél, szám; 4-et shiftelünk jobbra.
    CALL write_hexa_digit
    MOV DL, DH
    AND DL, 0Fh ; ÉS művelet, ezzel csak a felső része marad meg azaz az eleje - 0Fh = 11110000
    CALL write_hexa_digit

    ;Itt állítjuk vissza az C és D regisztereket, mivel verem ezért ellenkező irányba POP-olsz mint ahogy elvégezted a PUSH-t
    POP CX
    POP DX

    RET

write_hexa endp

write_hexa_digit proc
    PUSH DX

    ;CMP - Compare azaz összehasonlítás; CMP cél, forrás; befogja állítani a CF-et 1-re ha kisebb mint 10
    CMP DL, 10
    ;JB - Jump below; Azonnal ugrik a lenti non_hexa_digit részre ha CF = 1
    JB non_hexa_letter
    ;Ha 10 vagy nagyobb akkor nem ugorja át ezt a részt, amivel elérjük hogy a karakterünk az A=10, B=11, C=12... F=15 legyen
    ADD DL, "A"-"0"-10
    ;Ez ígyis - úgyis lejátszódik
non_hexa_letter:
    ADD DL, "0" ; Hozzáadjuk a 48-at hogy 0-ról induljon ascii táblában
    CALL write_char

    POP DX
    RET
write_hexa_digit endp

write_string proc ;BX-ben címzett karaktersorozat kiírása 0 kódig.
    PUSH DX ;DX mentése a verembe
    PUSH BX ;BX mentése a verembe
write_string_new:
    MOV DL, [BX] ;DL-be egy karakter betöltése
    OR DL, DL ;DL vizsgálata
    JZ write_string_end ;0 esetén kilépés
    CALL write_char ;Karakter kiírása
    INC BX ;BX a következő karakterre mutat
    JMP write_string_new ;A következő karakter betöltése
write_string_end:
    POP BX ;BX visszaállítása
    POP DX ;DX visszaállítása
    RET ;Visszatérés
write_string endp

read_string proc
    PUSH DX ;DX mentése a verembe
    PUSH BX ;BX mentése a verembe
read_string_new:
    CALL read_char ;Egy karakter beolvasása
    CMP DL, CR ;ENTER ellenőrzése
    JE read_string_end ;Vége, ha ENTER volt az utolsó karakter
    MOV [BX], DL ;Mentés az adatszegmensre
    INC BX ;Következő adatcím
    JMP read_string_new ;Következő karakter beolvasása
read_string_end:
    XOR DL, DL
    MOV [BX], DL ;Sztring lezárása 0-val
    POP BX ;BX visszaállítása
    POP DX ;DX visszaállítása
    RET ;Visszatérés
read_string endp

read_char proc
    PUSH AX ; AX-ben benne van az AL, AH, ezt beleteszem a verembe, azért mivel AH és AL-el dolgozunk,
    ;És szeretnénk hogy ez után a procedúra után is az legyen benne mint ami elötte volt
    MOV AH, 1; Beolvasás utasítás az 1
    INT 21h ; Elvégezzük az AH-ban lévő utasítást.
    ;AH-ban van az utasítás, és AL-be (Accumlator Low) fogja nekünk eltárolni azt amit beolvastunk a konzolról
    MOV DL, AL ; DL-be tároljuk el az AL-be beolvasott adatot, mivel azzal lehet dolgozni is.
    POP AX ; Vissza állítjuk AL, AH-t arra ami volt eredetileg a procedúra elött.
    RET
read_char endp

read_decimal proc
    PUSH AX
    PUSH BX

    MOV BL, 10
    XOR AX, AX; AX Törlése
read_decimal_new:
    CALL read_char; Beolvassuk DL-be a karaktert
    CMP DL, CR ; DL-t összevetjük a 13-al azaz enterrel
    JE read_decimal_end ; Ha enter akkor ugrunk

    SUB DL, "0" ; Karakter minusz 0 karakter 
    MUL BL ; AL*DL=AX, de amúgy a DL-be tárolódik vagy mi
    ADD AL, DL ; A következő helyiérték hozzáadása
    JMP read_decimal_new ; a következő karakter beolvasásáa

read_decimal_end:
    MOV DL, AL

    POP BX
    POP AX

    RET
read_decimal endp

write_decimal proc
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI

    XOR DH, DH
    MOV AX, DX
    MOV SI, 10
    XOR CX, CX

division_by_10:

    XOR DX, DX
    DIV SI
    PUSH DX
    INC CX ; CX Incrementálás
    OR AX, AX ; ha minden egyes értéke 0 akkor a státusz azaz CF az 0 lesz így megáll, minden más esetben 1
    JNE division_by_10
write:
    POP DX; ez tuti kisebb mint 10 így lehet használni a write hexa-t
    CALL write_hexa_digit
    LOOP write

    POP SI
    POP DX
    POP CX
    POP AX

    RET
write_decimal endp

write_screen proc
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AX, dgroup ;Adatszegmens beállítása 
    MOV DS, AX 
    MOV AX, 0B800h ;Képernyő-memória szegmenscíme ES-be 
    MOV ES, AX 
    XOR AX, AX ;AX törlése 
    MOV BL, 160 ;Szorzó betöltése BL-be 
    MOV AL, y ;Y koordináta betöltése AL-be 
    DEC AL ;AL-1, az 1. karakter a memória 0. címén van
    MUL BL ;AL szorzása 160-nal 
    MOV DI, AX ;DI-be a sorszámból számított memóriahely 
    XOR AX, AX ;AX törlése 
    MOV AL, x ;X koordináta betöltése AL-be 
    DEC AL ;AL-1, az 1. karakter a memória 0. címén van
    SHL AL, 1 ;AL szorzása 2-vel (1-el balra shift) 
    ADD DI, AX ;DI-hez hozzáadjuk az oszlopszámból 
    ;számított memóriahelyet 
    MOV AL, kar ;AL-be a karakterkód 
    MOV AH, attr ;AH-ba a karakter attribútuma 
    MOV ES:[DI], AX ;Betöltés a képernyő-memória kiszámított címére

    POP DX
    POP BX
    POP AX

    RET
write_screen endp

exit_program proc
    MOV AH, 4Ch ; Kilépés a programból
    INT 21h
    RET
exit_program endp

END main
