*-----------------------------------------------------------
* Title      :Plumber VS Rabbids
* Written by :Izabela Zelek
* Date       :10-03-2021
* Description:The player has to kill rabbids to gain money and buy a better weapon and more health potions.
*-----------------------------------------------------------

*-------------------------------------------------------
* STARTING MEMORY ADDRESS FOR THE PROGRAMME $1000
*-------------------------------------------------------
    
    ORG $1000

*-------------------------------------------------------
*PLAY AS A PLUMBER JUST TRYING TO GET THEIR JOB BACK
*-------------------------------------------------------

*-------------------------------------------------------
*VALIDATION VALUES TO BE USED, MODIFY AS NEEDED
*ADD ADDITIONAL VALIDATION VALUES AS REQUIRED
*-------------------------------------------------------
EXIT        EQU 0      USED TO EXIT ASSEMBLY PROGRAM
OWNED_POTIONS EQU 1      MIN NUMBER OF POTIONS
MAX_POTIONS EQU 9      MAX NUMBER OF POTIONS
OWNED_WEAPONS EQU 1      MIN WEAPON LEVEL
MAX_WEAPONS EQU 3      MAX WEAPON LEVEL
WIN_POINT   EQU 5      POINTS ACCUMILATED ON WIN
LOSE_POINT  EQU 8      POINTS DEDUCTED ON A LOSS

MINE_LOC    EQU 100    USED BELOW FOR SOME SIMPLE COLLISION DETECTION USING CMP
                       * EXAMPLE FOR A HIT


*START OF GAME
START:
    MOVE.B  #OWNED_POTIONS,$4000 PUT POTION AMOUNT IN MEMORY LOCATION $4000
    LEA     $4000,A3   ASSIGN ADDRESS A3 TO THAT MEMORY LOCATION
    MOVE.B  #100,$4008 PUT MONEY IN MEMORY LOCATION $4008
    LEA     $4008,A4   ASSIGN ADDRESS A4 TO THAT MEMORY LOCATION
    MOVE.B  #OWNED_WEAPONS,$4016 PUT WEAPON LEVEL IN MEMORY LOCATION $4008
    LEA     $4016,A5   ASSIGN ADDRESS A4 TO THAT MEMORY LOCATION



    BSR     WELCOME    BRANCH TO THE WELCOME SUBROUTINE
    BSR     INPUT      BRANCH TO THE INPUT SUBROUTINE
    BSR     GAME       BRANCH TO THE GAME SUBROUTINE
*GAME LOOP
    ORG     $3000      THE REST OF THE PROGRAM IS TO BE LOCATED FROM 3000 ONWARDS

*-------------------------------------------------------
*-------------------GAME SUBROUTINE---------------------
*-------------------------------------------------------
GAME:
    BSR     GAMELOOP   BRANCH TO GAMELOOP SUBROUTINE
    RTS                RETURN FROM GAME: SUBROUTINE
          
END:
    SIMHALT

*-------------------------------------------------------
*-------------------WELCOME SUBROUTINE------------------
*-------------------------------------------------------
WELCOME:
    BSR     ENDL            BRANCH TO ENDL SUBROUTINE
    LEA     WELCOME_MSG,A1  ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          MOVE LITERAL 14 TO DO
    TRAP    #15             TRAP AND INTERPRET VALUE IN D0
    LEA     INSTRUCT_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15

    RTS                     RETURN FROM WELCOME: SUBROUTINE

*-------------------------------------------------------
*---------GAMEPLAY INPUT VALUES SUBROUTINE--------------
*-------------------------------------------------------    
INPUT:
    BSR     POTIONS
    BSR     PROMPT         BRANCH TO WEAPONSS INPUT SUBROUTINE
    RTS

*-------------------------------------------------------
*----------------GAMELOOP (MAIN LOOP)-------------------
*------------------------------------------------------- 
GAMELOOP:
    BSR     UPDATE          BRANCH TO UPDATE GAME SUBROUTINE        
    BSR     DRAW            BRANCH TO DRAW SCREEN SUBROUTINE
    BSR     GAMEPLAY        BRANCH TO GAMEPLAY SUBROUTINE
    BSR     HUD             BRANCH TO DISPLAY HUD SUBROUTINE
    BSR     REPLAY          BRANCH TO REPLAY GAME SUBROUTINE
    RTS                     RETURN FROM GAMELOOP: SUBROUTINE

*-------------------------------------------------------
*----------------UPDATE QUEST PROGRESS------------------
*  COMPLETE QUEST
*------------------------------------------------------- 
UPDATE:
    BSR     ENDL            PRINT A CR AND LF
    BSR     DECORATE        DECORATE WITH DOTS USING A LOOP
    LEA     UPDATE_MSG,A1   
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE
    RTS
*-------------------------------------------------------
*-----------------DRAW QUEST UPDATES--------------------
* DRAW THE GAME PROGRESS INFORMATION, STATUS REGARDING
* QUEST
*------------------------------------------------------- 
DRAW:
    BSR     ENDL
    BSR     DECORATE
    LEA     DRAW_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE
    RTS

*-------------------------------------------------------
*-------------------------WEAPONS-----------------------
* NUMBER OF WEAPONS
*-------------------------------------------------------   
WEAPONS:
    BSR     ENDL
    LEA     WEAPONS_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A5),D1
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    BSR     DECORATE
    RTS
    
PROMPT:
    BSR     WEAPONS
    LEA     PRESS_ENTER,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0   
    TRAP    #15
    LEA     SHOP_PROMPT,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0   
    TRAP    #15
    MOVE    D1,D0
    CMP #1,D1
    BNE GAME
    BSR SHOP
    RTS

*-------------------------------------------------------
*--------------------POTIONS INVENTORY---------------------
* NUMBER OF POTIONS TO BE USED IN A QUEST 
*-------------------------------------------------------
POTIONS:
    BSR     DECORATE
    LEA     POTIONS_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D1
    MOVE.B  #3,D0
    TRAP    #15

    BSR     ENDL            BRANCH TO ENDL SUBROUTINE
    RTS
*-------------------------------------------------------
*---GAME PLAY (QUEST PROGRESS)--------------------------
*------------------------------------------------------- 
GAMEPLAY:
    BSR     ENDL
    BSR     DECORATE
    LEA     GAMEPLAY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0
    TRAP    #15
    BSR     DECORATE
    BSR     COLLISION
    RTS

*-------------------------------------------------------
*-----------------HEADS UP DISPLAY (SCORE)--------------
* RETRIEVES THE SCORE FROM MEMORY LOCATION
*-------------------------------------------------------   
HUD:

    BSR     ENDL
    BSR     DECORATE
    LEA     HUD_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D1     RETRIEVE THE VALUE A3 POINT TO AND MOVE TO D1
    MOVE.B  #3,D0       MOVE LITERAL 3 TO D0
    TRAP    #15         INTREPRET VALUE IN D0, WHICH 3 WHICH DISPLAYS D1
    BSR     DECORATE
    RTS

*-------------------------------------------------------
*-----------------------BEING ATTACKED------------------
* THIS COULD BE USED FOR COLLISION DETECTION
*-------------------------------------------------------
COLLISION:
    MOVE.B  #MINE_LOC,D1
    CMP     #100,D1 IS( X == 100)?
	BNE     COLLISION_MISS IF X IS EQUAL TO 100, THEN HIT
COLLISION_HIT:
    *HIT
    LEA     HIT_MSG,A1
    MOVE    #14,D0
    TRAP    #15
    RTS
    
COLLISION_MISS:
    *MISS
    LEA     MISS_MSG,A1
    MOVE    #14,D0
    TRAP    #15
    RTS

*-------------------------------------------------------
*--------------------------LOOP-------------------------
*-------------------------------------------------------
LOOP:
    MOVE.B  #5, D3 LOOP COUNTER D3=5
NEXT:
    LEA     LOOP_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
	SUB     #1,D3   DECREMENT LOOP COUNTER
    BNE     NEXT    REPEAT UNTIL D0=0

*-------------------------------------------------------
*------------------SCREEN DECORATION--------------------
*-------------------------------------------------------
DECORATE:
    MOVE.B  #60, D3
    BSR     ENDL
OUT:
    LEA     LOOP_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
	SUB     #1,D3   DECREMENT LOOP COUNTER
    BNE     OUT	    REPEAT UNTIL D0=0
    BSR     ENDL
    RTS
    
*-------------------------------------------------------
*------------------------REPLAY-------------------------
*-------------------------------------------------------
REPLAY:
    BSR     ENDL
    LEA     REPLAY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #4,D0
    TRAP    #15

    CMP     #EXIT,D1
    BEQ     END         IF SR Z REGISTER CONTAINS 1 BEQ => BRANCH EQUALS
    BSR     GAMELOOP

ENDL:
    MOVEM.L D0/A1,-(A7)
    MOVE    #14,D0
    LEA     CRLF,A1
    TRAP    #15
    MOVEM.L (A7)+,D0/A1
    RTS

*-------------------------------------------------------
*-------------------SHOP--------------------
*-------------------------------------------------------
SHOP:
    BSR     ENDL
    BSR     DECORATE
    LEA     SHOP_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    LEA     PRESS_ENTER,A1 
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0   
    TRAP    #15
    BSR     DECORATE
    BSR     SHOP_ASK
    RTS
SHOP_ASK:
    LEA     PRICE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0   
    TRAP    #15
    
    MOVE    D1,D0   GETS INPUT FROM PLAYER AND LETS BUY STUFF
    CMP     #1,D1
    BNE     NEXT_ITEM
    ADD.B   #1,(A3)
    BSR     ENDL
    BSR     POTIONS
    BSR     WEAPONS
    BSR     ENDL
    BSR     SHOP_ASK
    RTS
 NEXT_ITEM:
    CMP     #2,D1
    BNE     GAME
    ADD.B   #1,(A5)
    BSR     ENDL
    BSR     POTIONS
    BSR     WEAPONS
    BSR     ENDL
    BSR     SHOP_ASK

    RTS

    
   
*-------------------------------------------------------
*-------------------DATA DELARATIONS--------------------
*-------------------------------------------------------

CRLF:           DC.B    $0D,$0A,0
WELCOME_MSG:    DC.B    '************************************************************'
                DC.B    $0D,$0A
                DC.B    'Youve always been a very dedicated plumber. Always done on time and without' 
                DC.B    $0D,$0A
                DC.B    'leaks. You are simply, one of the best. Or at least you were...'
                DC.B    $0D,$0A
                DC.B    'All of a sudden these... bunny-eared plumber wannabes showed up and took your'
                DC.B    $0D,$0A
                DC.B    'jobs. I mean seriously, what kind of self-respected plumber works for free?!?!'
                DC.B    $0D,$0A
                DC.B    'Its time to show these fakers, who the real Plumber Boss is.'
                DC.B    $0D,$0A
                DC.B    $0D,$0A,0
POTION_MSG:     DC.B    'POTION ....'
                DC.B    $0D,$0A
                DC.B    'ENTER POTION : ',0
POTIONS_MSG:    DC.B    'Potions owned:',0
INSTRUCT_MSG:   DC.B    'Your mission is simple. Defeat the vermin and take back your well-earned title.'
                DC.B    $0D,$0A
                DC.B    'Take down as many of them as you can before they take you down.'
                DC.B    $0D,$0A
                DC.B    'Viva la revolution'
                DC.B    $0D,$0A
                DC.B    '************************************************************'
                DC.B    $0D,$0A
                DC.B    $0D,$0A,0
PRESS_ENTER:    DC.B    $0D,$0A
                DC.B    'Press enter to continue'
                DC.B    $0D,$0A,0
WEAPONS_MSG:    DC.B    'Current Weapon Level:',0
GAMEPLAY_MSG:   DC.B    'ADD GAMEPLAY !',0
UPDATE_MSG:     DC.B    'UPDATE GAMEPLAY !',0
DRAW_MSG:       DC.B    'DRAW SCREEN !',0
HIT_MSG:        DC.B    'STRIKE!',0
MISS_MSG:       DC.B    'MISS!',0
LOOP_MSG:       DC.B    '.',0
REPLAY_MSG:     DC.B    'ENTER 0 TO QUIT ANY OTHER NUMBER TO REPLAY : ',0
HUD_MSG:        DC.B    'SCORE : ',0
SHOP_MSG:       DC.B    '************************************************************'
                DC.B    $0D,$0A
                DC.B    '*A very obviously dressed up Rabbid shows up*'
                DC.B    $0D,$0A
                DC.B    'Greetings, traveller!'
                DC.B    $0D,$0A
                DC.B    'Im sure I have something up to your liking.'
                DC.B    $0D,$0A
                DC.B    '************************************************************'
                DC.B    $0D,$0A,0
SHOP_PROMPT:    DC.B    'Would you like to visit the shop?'
                DC.B    $0D,$0A
                DC.B    '1 - Enter Shop, Enter- Proceed'
                DC.B    $0D,$0A,0
PRICE_MSG:      DC.B    'Health Potion- 10'
                DC.B    $0D,$0A
                DC.B    'Sword Upgrade- 50'
                DC.B    $0D,$0A
                DC.B    '************************************************************'
                DC.B    $0D,$0A
                DC.B    '1 - Buy a Health Potion, 2 - Buy a weapon upgrade, Enter - Proceed'
                DC.B    $0D,$0A,0
                
HEALTH:     DS.W    1   PLAYERS HEALTH
SCORE:      DS.W    1   RESERVE SPACE FOR SCORE

    END START






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
