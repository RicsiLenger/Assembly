; Készítsen programot, amely beolvas egy színkódot (háttérszín). Majd a képernyőt beállítja a megadott háttérszínre. 

.MODEL SMALL
.STACK
.DATA
    CR EQU 13 ; CR(Enter karakter)
    LF EQU 10 ; LF (Új sor)
    EX EQU 10
.CODE
	MAIN PROC
		CALL clear_screen
		CALL fill_with_attr
		CALL sys_exit
	MAIN ENDP

    fill_with_attr PROC;description
        CALL read_decimal				; kivant hatterszin kodjanak beolvasasa
		MOV CL, DL						; beolvasott hatterszin CL-be mentese a hosszabb tavu tarolas erdekeben

		MOV AX, DGROUP 					; adatszegmens cimenek kinyerese
		MOV DS, AX 						; adatszegmens cimenek tarolasa DS-ben (hosszu tavu tarolas)
		MOV AX, 0B800h 					; kepernyo-memoria szegmenscimenek ES-be mentese // 0B800h is the address of VGA card for text mode = ami megfelel a kepernyo elso karakterpoziciojanak (bal felso sarok) memoriacimenek
		MOV ES, AX 						; saving AX into ES, so ES holds the address of VGA card
		XOR AX, AX 						; AX torlese 
		MOV BL, 160 					; szorzo betoltese BL-be	
		PUSH DX

		MOV DL, 1 ; loop counter
		print_horizontal:
			MOV AL, DL 					; Y értékének beállítása: mindig az aktuális DL értékére állítjuk az AL-t ( y = DL értéke )
			MUL BL 						; AL szorzása 160-nal 
			MOV DI, AX 					; DI-be a sorszámból számított memóriahely 
			XOR AX, AX 					; AX törlése

			MOV AL, CH 					; X értékének beállítása: iteráció által (CH a loop2 counter, ami mindig incrementálódik)
			DEC AL 						; karakterhez tartozó memóriacím értékének felvétele AL-be
			SHL AL, 1 					; AL-ben tárolt karakterhez tartozó memóriacím szorzása 2-vel (1-el balra shift)
			ADD DI, AX 					; AL-hez tartozó memóriacímet hozzáadja a DI-hez (offszetcím beállítása)
			XOR AX, AX					; AX tartalmanak torlese

			mov AH, CL 					; beolvasott hatterszin beallitasa
			mov ES:[DI], AX				; hatter beszinezese (attributum kiiratasa karakter nelkul)
		validating:
			INC CH						; belso loop counter incrementalasa
			CMP CH, 81					; belso loop 80x kell lefusson - ennek validalasa ( mert a kijelzo 80x25-os)
			JL print_horizontal			; amig kisebb mint 81 a counter, ujra meghivjuk a belso processt

			INC DL						; kulso loop counter novelese (kovetkezo sort kezdjuk igy kitolteni)
			CMP DL, 25					; a kulso loop 25x kell lefusson - ennek validalasa (mert a kijelzo 80x25-os)
			JG ending					; amennyiben kitoltottuk az osszes sort, befejezzuk

			MOV CH, 1					; ide csak akkor jutunk el, ha CH = 80 volt --> egy sort mar kitoltottunk balrol jobbra, most visszallitjuk az irast az x=0-ra hogy az ujabb sort is ki tudjuk tolteni 80 karakterrel
			JMP print_horizontal		; kitoltjuk az uj sort is 80 karakterel
		ending:
            POP DX
			RET

    fill_with_attr ENDP
    clear_screen PROC
            xor AL,AL
            xor CX,CX
            MOV DH,49          
            MOV DL,79           
            MOV BH,7         
            MOV AH,6
            INT 10h          
            RET
        clear_screen ENDP

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

        read_decimal PROC
            PUSH AX ;AX mentese a verembe
            PUSH BX ;BX mentese a verembe
            MOV BL, 10 ;BX-be a szamrendszer alapszama, ezzel szorzunk
            XOR AX, AX ;AX register torlese
            read_decimal_new:
                CALL read_char ;Egy karakter beolvasasa
                CMP DL, CR ;ENTER ellenorzese
                JE read_decimal_end ;Vege, ha ENTER volt az utolso karakter
                SUB DL, "0" ;Karakterkod minusz ”0” kodja
                MUL BL ;AX szorzasa 10-zel
                ADD AL, DL ;A kovetkezo helyi ertek hozzaadasa
                JMP read_decimal_new ;A kovetkezo karakter beolvasasa
            read_decimal_end:
                MOV DL, AL ;DL-be a beirt szam
                POP BX ;AB visszaallitasa
                POP AX ;AX visszaallitasa
                RET ;Visszateres a hivo rutinba
        read_decimal ENDP

        write_char PROC ;A DL-ben levo karakter kiirasa a kepernyore
            PUSH AX ;AX mentese a verembe
            MOV AH, 2 ; AH-ba a kepernyore iras funkciokodja
            INT 21h ; Karakter kiirasa
            POP AX ;AX visszaallitasa
            RET ;Visszateres a hivo rutinba
        write_char ENDP

        cr_lf PROC
            PUSH DX ;DX mentese a verembe
            MOV DL, CR
            CALL write_char ;kurzor a sor elejere
            MOV DL, LF
            CALL write_char ;Kurzor egy sorral lejjebb
            POP DX ;DX visszaallitasa
            RET ;Visszateres a hivo rutinba
        cr_lf ENDP

        sys_exit PROC
            MOV AH, 4CH ; system CALL: sys_exit
            INT 21H ; interrupt to perform the previous system CALL
        sys_exit ENDP

END main