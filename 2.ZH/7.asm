;Visszafele string. Bekéréses megoldás

.MODEL SMALL
.STACK 100h
.DATA
    Buffer DB 100 DUP(0) ; Puffer a felhasználói beviteli szöveg tárolására
    Buffer_LEN EQU $ - Buffer
    CR EQU 13 ; CR (Enter karakter)
    LF EQU 10 ; LF (Új sor)

.CODE
    MAIN PROC
        MOV AX, @DATA ; Adatszegmens inicializálása
        MOV DS, AX

        CALL clear_screen ; Képernyő törlése
        CALL read_chars ; Szöveg beolvasása a pufferbe
        CALL cr_lf ; Új sorba ugrás
        CALL write_string_backwards ; 
        CALL sys_exit ; Kilépés
    MAIN ENDP

    ; ===== Karakterek beolvasása =====
    read_chars PROC
        MOV DI, OFFSET Buffer ; A puffer kezdőcímét DI-be helyezzük
    next_char:
        CALL read_char ; Egy karakter beolvasása DL-be
        CMP DL, CR ; Ellenőrizzük, hogy az Entert kaptuk-e
        JE done_input ; Ha igen, kilépünk a beolvasásból
        MOV [DI], DL ; A beolvasott karaktert eltároljuk a pufferben
        INC DI ; Következő pozíció a pufferben
        JMP next_char ; Folytatjuk a beolvasást
    done_input:
        MOV BYTE PTR [DI], 0 ; A puffer végét nullával zárjuk (string terminátor)
        RET
    read_chars ENDP

    ;visszafele string
  write_string_backwards PROC
		MOV AX, DGROUP 					; adatszegmens cimenek kinyerese
		MOV DS, AX 						; adatszegmens cimenek tarolasa DS-ben (hosszu tavu tarolas)
		LEA BX, Buffer + Buffer_LEN - 2 ; loop countert az utolso valos karakterre allitjuk // -2 azert kell, hogy a tulcsordulast es a binaris 0-t (= endbitet) elkerüljük
		LEA CX, Buffer 					; segedregiszter bezetese, mely az adott szoveg elso karakterere mutat // szukseges a ciklus megallitasahoz -- igy tudjuk megallitani a kiiratast amikor elerunk a string elso karakterehez

		previous_char:
			MOV DL, [BX] 				; a pointer adott cimen található érték (= karakter) kimentése DL-be  // a cimet folyamatosan növeljük BL incrementálásval
			OR DL, DL					; DL reset 
			CALL write_char				; karakter kiiratasa
			CMP BX, CX 					; teszteljuk, hogy elertunk-e a string elso karakterehez
			JE stop						; ha elertunk visszafele a string elso karakterehez, kilepunk

			DEC BX 						; decere,emtomg loop counter so that we'll skip to the previous character
			JMP previous_char
		stop:
			RET
	write_string_backwards ENDP

    ; ===== Egy karakter beolvasása =====
    read_char PROC
        PUSH AX ; AX mentése a verembe
        MOV AH, 1 ; Beolvasási funkciókód
        INT 21h ; Karakter beolvasása
        MOV DL, AL ; Beolvasott karakter DL-be másolása
        POP AX ; AX visszaállítása
        RET
    read_char ENDP

    ; ===== Egy karakter kiírása =====
    write_char PROC
        PUSH AX ; AX mentése a verembe
        MOV AH, 2 ; Kiírás funkciókód
        INT 21h ; Karakter kiírása
        POP AX ; AX visszaállítása
        RET
    write_char ENDP

    ; ===== Új sor kezdése =====
    cr_lf PROC
        PUSH DX ; DX mentése a verembe
        MOV DL, CR
        CALL write_char ; Kurzor a sor elejére
        MOV DL, 10 ; Új sor
        CALL write_char
        POP DX ; DX visszaállítása
        RET
    cr_lf ENDP

    ; ===== Képernyő törlése =====
    clear_screen PROC
        XOR AX, AX
        XOR CX, CX
        MOV DH, 49 ; Magasság
        MOV DL, 79 ; Szélesség
        MOV BH, 7 ; Színezés
        MOV AH, 6 ; Görgetés funkció
        INT 10h ; BIOS megszakítás
        RET
    clear_screen ENDP

    ; ===== Kilépés =====
    sys_exit PROC
        MOV AH, 4Ch ; Kilépés funkció
        INT 21h ; Kilépés
        RET
    sys_exit ENDP

END MAIN
