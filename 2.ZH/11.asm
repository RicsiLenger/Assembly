;Készítsen programot, amely beolvas egy karaktert. Majd a beolvasott karakterből (tetszőleges attribútummal) kitölti a képernyőt.

.MODEL SMALL
.STACK
.DATA
	att DB 7
    CR EQU 13 ; CR(Enter karakter)
    LF EQU 10 ; LF (Új sor)
    EX EQU 10

.CODE
	MAIN PROC
		CALL clear_screen
		CALL fill_with_char
		CALL sys_exit
	MAIN ENDP

	fill_with_char PROC
		CALL read_char					; karakter beolvasasa - ezzel keretezzuk be a kepernyot
		MOV CL, DL						; beolvasott karakter CL-be mentese a hosszabb tavu tarolas erdekeben

		MOV AX, DGROUP 					; adatszegmens cimenek kinyerese
		MOV DS, AX 						; adatszegmens cimenek tarolasa DS-ben (hosszu tavu tarolas)
		MOV AX, 0B800h 					; kepernyo-memoria szegmenscimenek ES-be mentese // 0B800h is the address of VGA card for text mode = ami megfelel a kepernyo elso karakterpoziciojanak (bal felso sarok) memoriacimenek
		MOV ES, AX 						; saving AX into ES, so ES holds the address of VGA card
		XOR AX, AX 						; AX torlese 
		MOV BL, 160 					; szorzo betoltese BL-be	
		PUSH DX

		MOV DL, 1 						; kulso loop counter inicializalasa ( ez a sorokat lepteti -- 25 sort kell kitolteni )
		MOV CH, 1						; belso loop counter inicializalasa ( ez a karaktereket irja egy sorban -- 80 karakter kell / sor )
		print_horizontal:
			MOV AL, DL 					; Y értékének beállítása: mindig az aktuális DL értékére állítjuk az AL-t ( y = DL értéke )
			MUL BL 						; AL szorzása 160-nal 
			MOV DI, AX 					; DI-be a sorszámból számított memóriahely 
			XOR AX, AX 					; AX törlése	

			MOV AL, CH 					; X értékének beállítása: iteráció által (CH a loop2 counter, ami mindig incrementálódik)
			DEC AL 						; karakterhez tartozó memóriacím értékének felvétele AL-be
			SHL AL, 1 					; AL-ben tárolt karakterhez tartozó memóriacím szorzása 2-vel (1-el balra shift)
			ADD DI, AX 					; AL-hez tartozó memóriacímet hozzáadja a DI-hez (offszetcím beállítása)

			MOV AL, CL					; consolerol beolvasott karakter átadása 
			;MOV AL, "K"				; ALTERNATIVE OPTION: karakter értékének megadása
			MOV AH, att 				; karakter attríbutumértékének beállítása a megadott konstans alapjan (= piros szín)
			MOV ES:[DI], AX				; karakter kiíratása a megfelelő koordinátára
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
	fill_with_char ENDP


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

	read_char PROC ; AX = input, DL = output
        PUSH AX
        MOV AH,1
        INT 21h
        MOV DL, AL
        POP AX
		CMP DL, EX ;exit ellenorzese
		JE read_char_exit
        RET
		read_char_exit:
			XOR DL, DL ; a mar beolvasott ertek torlese
			MOV AH, 4CH ; system CALL: sys_exit
			INT 21H ; interrupt to perform the previous system CALL
    read_char ENDP

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