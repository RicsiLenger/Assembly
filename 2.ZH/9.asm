;Készítsen programot, amely beolvas egy karaktert, illetve egy attribútum értéket. Majd a beolvasott karaktert, a megadott attribútummal megjeleníti a képernyőn közepén.

.MODEL SMALL
.STACK
.DATA
	String DB "kiirando karakter, attributum (integer < 256) [ENTER]", 0
    CR EQU 13 ; CR(Enter karakter)
    LF EQU 10 ; LF (Új sor)
    EX EQU 10

.CODE
	MAIN PROC
		CALL clear_screen
		CALL write_char_and_attr_to_center
		CALL sys_exit
	MAIN ENDP

	write_char_and_attr_to_center PROC
		MOV AX, DGROUP 					; adatszegmens cimenek kinyerese
		MOV DS, AX 						; adatszegmens cimenek tarolasa DS-ben (hosszu tavu tarolas)
		MOV AX, 0B800h 					; kepernyo-memoria szegmenscimenek ES-be mentese // 0B800h is the address of VGA card for text mode = ami megfelel a kepernyo elso karakterpoziciojanak (bal felso sarok) memoriacimenek
		MOV ES, AX 						; saving AX into ES, so ES holds the address of VGA card
		XOR AX, AX 						; AX torlese 
		MOV BL, 160 					; szorzo betoltese BL-be	

		read_character:
			CALL read_char				; reading the character to be printed
			MOV AL, DL					; saving the character that we've read in into AL so we can read in the attributes without overwriting the saved char
			;MOV AL, 'T' 				; ALTERNATIVE OPTION: manualisan menthetjuk az AL-be a kiírandó karaktert (kod megvaltoztatasa szukseges ez esetben - hagyjuk el a read_charactert !) 
		read_attribute:
			CALL read_decimal			; reading in the attribute
			MOV AH, DL					; saving the attribute that we've read in into AH
			;MOV AH, 128 * 1 + 16*0 + 4 ; ALTERNATIVE OPTION: karakter attributumat itt is definialhatjuk konstans helyett (ilyenkor kommenteljuk ki az egyel feljebb levo utasitast)
		print_to_center:
			PUSH AX
			MOV AH, 0h					; kepernyouzemmodba valtas
			MOV AL, 3h					; 80x25os felbontas, szines uzemmod beallitasa
			INT 10H						; system interrupt a fenti parancsok vegrehajtasaert
			POP AX
			MOV DI, 1838 				; kepernyo kozepenek offsetcimenek beallitasa
			MOV ES:[DI], AX 			; kiiratas a képernyő-memória kiszámított címére
		RET
	write_char_and_attr_to_center ENDP

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