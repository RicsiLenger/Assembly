;Készítsen programot, amely beolvas egy karaktert. Majd a beolvasott karakterből (tetszőleges attribútummal) bekeretezi a képernyőt.

.MODEL SMALL
.STACK
.DATA
	att DB 128 * 0 + 16 * 0 + 4
    CR EQU 13 ; CR(Enter karakter)
    LF EQU 10 ; LF (Új sor)
    EX EQU 10

.CODE
	MAIN PROC
		CALL clear_screen
		CALL framing
		CALL sys_exit
	MAIN ENDP

	framing PROC		
		CALL read_char					; karakter beolvasasa - ezzel keretezzuk be a kepernyot
		MOV CL, DL						; beolvasott karakter CL-be mentese a hosszabb tavu tarolas erdekeben
		
        MOV AX, DGROUP 					; adatszegmens cimenek kinyerese
		MOV DS, AX 						; adatszegmens cimenek tarolasa DS-ben (hosszu tavu tarolas)
		MOV AX, 0B800h 					; kepernyo-memoria szegmenscimenek ES-be mentese // 0B800h is the address of VGA card for text mode = ami megfelel a kepernyo elso karakterpoziciojanak (bal felso sarok) memoriacimenek
		MOV ES, AX 						; saving AX into ES, so ES holds the address of VGA card
		XOR AX, AX 						; AX torlese 
		MOV BL, 160 					; szorzo betoltese BL-be	
		
        MOV DL, 1 						; loop counter inicializalasa
		upper_horizontal:
			MOV AL, 1 					; felső sor beállítása: mindig y=1-re állítjuk az AL-t
			MUL BL 						; AL szorzása 160-nal 
			MOV DI, AX 					; DI-be a sorszámból számított memóriahely 
			XOR AX, AX 					; AX törlése	
			
			MOV AL, DL 					; X értékének változtatása iteráció által (DL a loop counter, ami mindig incrementálódik)
			DEC AL 						; karakterhez tartozó memóriacím értékének felvétele AL-be
			SHL AL, 1 					; AL-ben tárolt karakterhez tartozó memóriacím szorzása 2-vel (1-el balra shift)
			ADD DI, AX 					; AL-hez tartozó memóriacímet hozzáadja a DI-hez (offszetcím beállítása)
			MOV AL, CL					; consolerol beolvasott karakter átadása 
			;MOV AL, "K"				; ALTERNATIVE OPTION: karakter értékének megadása
			MOV AH, att 				; karakter attríbutumértékének beállítása a megadott konstans alapjan (= piros szín)
			MOV ES:[DI], AX				; karakter kiíratása a megfelelő koordinátára
		lower_horizontal:
			MOV AL, 24 					; alsó sor beállítása: mindig y=24-re állítjuk az AL-t
			MUL BL 						; AL szorzása 160-nal 
			MOV DI, AX 					; DI-be a sorszámból számított memóriahely 
			XOR AX, AX 					; AX törlése	
			
			MOV AL, DL 					; X értékének változtatása iteráció által (DL a loop counter, ami mindig incrementálódik)
			DEC AL 						; karakterhez tartozó memóriacím értékének felvétele AL-be
			SHL AL, 1 					; AL-ben tárolt karakterhez tartozó memóriacím szorzása 2-vel (1-el balra shift)
			ADD DI, AX 					; AL-hez tartozó memóriacímet hozzáadja a DI-hez (offszetcím beállítása)
			MOV AL, CL					; consolerol beolvasott karakter átadása 
			;MOV AL, "K"				; ALTERNATIVE OPTION: karakter értékének megadása
			MOV AH, att 				; karakter attríbutumértékének beállítása a megadott konstans alapjan (= piros szín)
			MOV ES:[DI], AX				; karakter kiíratása a megfelelő koordinátára
		increment_loopcounter_horizontal:	
			INC DL 						; DL értékének növelése
			CMP DL, 80					; loop countert megvizsgaljuk
			JL upper_horizontal 		; amíg el nem éri a 80 iterációt a DL, subrutint újrahívjuk
			MOV DL, 1 					; ha iteraltunk mar 80x, akkor a DL értékét visszaállítjuk és folytatjuk a vertical subrutinnal	
		right_vertical:
			MOV AL, DL 					; DL értéke változik az iterációkkal, ennek segítségével jutunk az alsó sorba       
			DEC AL             
			mul BL             
			MOV DI, AX
			XOR AX, AX
			
			MOV AL, 80 					; jobb oldal kiíratása --> X = 80
			DEC AL
			SHL AL, 1            
			ADD DI, AX
			MOV AL, CL					; consolerol beolvasott karakter átadása 
			;MOV AL, "K"				; ALTERNATIVE OPTION: karakter értékének megadása
			MOV AH, att 				; karakter attríbutumértékének beállítása a megadott konstans alapjan (= piros szín)
			MOV ES:[DI], AX				; karakter kiíratása a megfelelő koordinátára
		left_vertical:	
			MOV AL, DL           
			DEC AL             
			mul BL            
			MOV DI, AX     
			xor AX, AX
			
			MOV AL, 1 					; bal oldal kiíratása --> X = 1
			DEC AL
			SHL AL, 1          
			ADD DI, AX    
			MOV AL, CL					; consolerol beolvasott karakter átadása 
			;MOV AL, "K"				; ALTERNATIVE OPTION: karakter értékének megadása
			MOV AH, att 				; karakter attríbutumértékének beállítása a megadott konstans alapjan (= piros szín)
			MOV ES:[DI], AX				; karakter kiíratása a megfelelő koordinátára
		increment_loopcounter_vertical:	
			INC DL
			CMP DL, 24					; 24x akarunk kiiratni verticalisan, amint ezt elerjuk, befejezzuk a ciklust, amig nem addig ujrahivjuk a szubprocesst
			JG ending
			JMP right_vertical
		ending:
			RET
    framing  ENDP


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