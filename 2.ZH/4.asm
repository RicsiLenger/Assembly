;Írjon ki egy tetszőleges (konstatns) szöveget úgy hogy minden szó új sorba kerüljön. Bekéréses megoldás

.MODEL SMALL
.STACK 100h
.DATA
    Buffer DB 100 DUP(0) ; Puffer a felhasználói beviteli szöveg tárolására
    CR EQU 13 ; CR(Enter karakter)
    LF EQU 10 ; LF (Új sor)

.CODE
    MAIN PROC
        MOV AX, @DATA ; Adatszegmens inicializálása
        MOV DS, AX

        CALL clear_screen ; Képernyő törlése
        CALL read_chars ; Szöveg beolvasása a pufferbe
        CALL cr_lf ; Új sorba ugrás
        CALL write_words_in_newline ; 
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

    ; ===== Páratlan indexű karakterek kiírása =====
   write_words_in_newline PROC
		MOV AX, DGROUP 					; adatszegmens cimenek kinyerese
		MOV DS, AX 						; adatszegmens cimenek tarolasa DS-ben (hosszu tavu tarolas)
		LEA BX, Buffer 					; creating the first pointer of the string constant

		next_nonspace_char:
			MOV DL, [BX] 				; a pointer adott cimen található érték (= karakter) kimentése DL-be  // a cimet folyamatosan növeljük BL incrementálásval
			OR DL, DL 					; DL reset 
			JZ stop 					; ha elértük az endbitet, akkor megallunk (konstans , 0) <-- a 0 az endbit // JZ = jump near if 0
			CMP DL, ' '					; beolvasott ertek osszehasonlitasa SPACE karakterrel
			JE skip_space_with_newline	; ha SPACE-t olvastunk be, akkor azt kihagyjuk a kiiratasbol es uj sort nyitunk

			CALL write_char				; ha nem SPACE-t olvastunk be, kiiratjuk

			INC BX						; loop counter increase (moving to the next char)
			JMP next_nonspace_char
		skip_space_with_newline:
			CALL cr_lf					; printing a newline
			INC BX						; incrementing loop counter so that we'll skip to the next character
			JMP next_nonspace_char
		stop:
			RET
	write_words_in_newline ENDP

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
