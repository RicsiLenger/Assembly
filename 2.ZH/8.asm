;Készítsen programot, amely beolvas egy karaktert, illetve egy koordináta párt. Majd a beolvasott karaktert (tetszőleges attríbutummal) megjleníti a képernyőn, a megadott pozícióban. 

MODEL SMALL
.STACK
.DATA
	att DB 128 * 0 + 16 * 0 + 4
	String DB "Y-koordinata (<25) [ENTER], X-koordinata (<80) [ENTER], kiirando karakter", 0
    CR EQU 13 ; CR(Enter karakter)
    LF EQU 10 ; LF (Új sor)
    EX EQU 10

.CODE
	MAIN PROC
		CALL clear_screen
		CALL write_char_to_coordinate
	MAIN ENDP

	write_char_to_coordinate PROC
		MOV AX, DGROUP 					; adatszegmens cimenek kinyerese
		MOV DS, AX 						; adatszegmens cimenek tarolasa DS-ben (hosszu tavu tarolas)
		MOV AX, 0B800h 					; kepernyo-memoria szegmenscimenek ES-be mentese // 0B800h is the address of VGA card for text mode = ami megfelel a kepernyo elso karakterpoziciojanak (bal felso sarok) memoriacimenek
		MOV ES, AX 						; saving AX into ES, so ES holds the address of VGA card
		XOR AX, AX 						; AX torlese 
		MOV BL, 160 					; szorzo betoltese BL-be						
		
		read_y:
			CALL read_decimal			; reading Y coordinate from console
			MOV AL, DL					; saving the read-in decimal into AL
			;MOV AL, 10 				; ALTERNATIVE OPTION: defining the Y coordinate without console input (comment out the above 2 lines if you're using this)
			ADD AL, 1 					; correcting the Y coordinate for proper positioning (without ADD it would be shifted with 1 row upwards)
			DEC AL 						; AL-1, az 1. karakter a memoria 0. cimen van
			MUL BL 						; AL szorzása 160-nal 
			MOV DI, AX 					; DI-be mentjuk a sor szamabol szamitott memoriahelyet 
			XOR AX, AX 					; AX törlése 
		read_x:
			CALL read_decimal			; reading Y coordinate from console
			MOV AL, DL					; saving the read-in decimal into AL
			;MOV AL, 100 				; ALTERNATIVE OPTION: defining the X coordinate without console input (comment out the above 2 lines if you're using this)
			DEC AL 						; AL-1, az 1. karakter a memoria 0. cimen van
			SHL AL, 1 					; AL szorzasa 2-vel (1-el balra shift ?) 
			ADD DI, AX 					; DI-hez adjuk az oszlop szamabol szamitott memoriahelyet
		read_character:
			CALL read_char				; Reading the character to be printed
		print_character:
			PUSH DX
			CALL clear_screen			; clearing the screen
			POP DX
			MOV AL, DL					; saving the character that we've read in into AL
			;MOV AL, 'T' 				; ALTERNATIVE OPTION: manualisan menthetjuk az AL-be a kiírandó karaktert (kod megvaltoztatasa szukseges ez esetben - hagyjuk el a read_charactert !) 
			MOV AH, att					; saving the character's predefined attributes into AH register
			;MOV AH, 128 * 1 + 16*0 + 4 ; ALTERNATIVE OPTION: karakter attributumat itt is definialhatjuk konstans helyett (ilyenkor kommenteljuk ki az egyel feljebb levo utasitast)
			MOV ES:[DI], AX 			; kurzort betoltjuk a képernyő-memória megfelelően kiszámított címére
		RET			
	write_char_to_coordinate ENDP

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

    read_char PROC 
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

	cr_lf PROC
		PUSH DX ;DX mentese a verembe
		MOV DL,CR
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