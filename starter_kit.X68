*-----------------------------------------------------------
* Title      :Plumber VS Rabbids
* Written by :Izabela Zelek
* Date       :10-03-2021
* Description:The player has to kill rabbids to gain money and buy a better weapon and more health potions.
* Known Bugs: Health text gets shown twice during fight after 2 rounds of fighting.
*             Health sometimes bugs out and shows 0 or 245
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
OWNED_POTIONS EQU 2      MIN NUMBER OF POTIONS
OWNED_WEAPONS EQU 1      MIN WEAPON LEVEL
MAX_WEAPON    EQU 3      MAX WEAPON LEVEL
MONEY_AMOUNT  EQU 0     AMOUNT OF MONEY IN PLAYER'S POSSESSION
POTION_PRICE EQU 10     PRICE OF POTION IN SHOP
WEAPON_PRICE EQU 100     PRICE OF WEAPON UPGRADE IN SHOP
ENEMY_HEALTH EQU 80
HEALTH       EQU 100
MINE_LOC    EQU 100    USED BELOW FOR SOME SIMPLE COLLISION DETECTION USING CMP
DAMAGE      EQU 30


*START OF GAME
START:
    MOVE.B  #ENEMY_HEALTH,$4036
    LEA     $4036,A2
    MOVE.B  #OWNED_POTIONS,$4000 PUT POTION AMOUNT IN MEMORY LOCATION $4000
    LEA     $4000,A3   ASSIGN ADDRESS A3 TO THAT MEMORY LOCATION
    MOVE.B  #HEALTH,$4008
    LEA     $4008,A4
    MOVE.B  #OWNED_WEAPONS,$4016 PUT WEAPON LEVEL IN MEMORY LOCATION $4008
    LEA     $4016,A5   ASSIGN ADDRESS A4 TO THAT MEMORY LOCATION
    MOVE.B  #MONEY_AMOUNT,$4024
    LEA     $4024,A6

    
    MOVE.B  #POTION_PRICE,$4032




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
    BSR     MONEY
    BSR     SHOW_HEALTH
    BSR     POTIONS
    BSR     PROMPT         BRANCH TO WEAPONSS INPUT SUBROUTINE
    RTS

*-------------------------------------------------------
*----------------GAMELOOP (MAIN LOOP)-------------------
*------------------------------------------------------- 
GAMELOOP:
    BSR     MISSION_INFO    BRANCH TO UPDATE GAME SUBROUTINE        
    BSR     PLAYER_TURN     BRANCH TO PLAYER TURN SUBROUTINE
    BSR     ENEMY_TURN        BRANCH TO ENEMY_TURN SUBROUTINE
    BSR     PLAYER_TURN     BRANCH TO PLAYER TURN SUBROUTINE
    BSR     ENEMY_TURN        BRANCH TO ENEMY_TURN SUBROUTINE
    BSR     REPLAY          BRANCH TO REPLAY GAME SUBROUTINE
    RTS                     RETURN FROM GAMELOOP: SUBROUTINE

*-------------------------------------------------------
*----------------MISSION_INFO------------------
*  COMPLETE QUEST
*------------------------------------------------------- 
MISSION_INFO
    BSR     ENDL            PRINT A CR AND LF
    BSR     DECORATE        DECORATE WITH DOTS USING A LOOP
    LEA     MISSION_MSG,A1   
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE
    RTS
*-------------------------------------------------------
*-----------------PLAYER TURN UPDATES--------------------
* LETS PLAYER CHOOSE IF THEY WANT TO ATTACK OR USE POTION
*------------------------------------------------------- 
PLAYER_TURN:
    BSR     ENDL
    BSR     SHOW_HEALTH
    BSR     POTIONS
    BSR     DECORATE
    CMP     #1,(A2)
    BLT     WIN_FIGHT
    CMP     #1,(A4)
    BLT     LOSE_FIGHT
    LEA     PLAYERTURN_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0   
    TRAP    #15
    
    MOVE    D1,D0   GETS INPUT FROM PLAYER AND LETA CHOOSE OPTION
    CMP     #1,D1
    BNE     NEXT_CHOICE   IF OPTION 1 NOT CHOSEN, MOVES TO OPTION 2
    BSR     DECORATE  
    BSR     COLLISION   
    RTS

NEXT_CHOICE:
    CMP     #2,D1
    BNE     WRONG_CHOICE
    MOVE.B  (A3),D6
    CMP     #1,D6
    BGE     MINUS_POTION
    LEA     ZEROPOTION_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     PLAYER_TURN
    RTS
    
MINUS_POTION:
    MOVE.B  (A4),D7
    CMP     #100,D7
    BGE     CANT_USE_POTION
    LEA     USE_POTION,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE
    SUB.B   #1,(A3)
    ADD.B   #60,(A4)
    BSR SHOW_HEALTH
    BSR POTIONS
    RTS
   
CANT_USE_POTION:
    LEA     FULL_HEALTH,A1
    MOVE.B  #14,D0
    TRAP    #15
    BSR     DECORATE 
    BSR     PLAYER_TURN
    RTS 
WRONG_CHOICE:
    LEA     NOT_CORRECT,A1
    MOVE.B  #14,D0
    TRAP    #15
    BNE PLAYER_TURN
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
*--------------------Money display---------------------
*-------------------------------------------------------
MONEY:
    BSR     DECORATE
    LEA     MONEY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A6),D1
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    RTS



*-------------------------------------------------------
*--------------------POTIONS INVENTORY---------------------
* NUMBER OF POTIONS TO BE USED IN A QUEST 
*-------------------------------------------------------
POTIONS:
    BSR     ENDL
    LEA     POTIONS_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A3),D1
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL            BRANCH TO ENDL SUBROUTINE
    RTS
    
    
*-------------------------------------------------------
*--------------------SHOW HEALTH---------------------
* SHOWS AMOUNT OF HEALTH 
*-------------------------------------------------------
SHOW_HEALTH:
    BSR     ENDL
    LEA     HEALTH_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  (A4),D1
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL            BRANCH TO ENDL SUBROUTINE
    RTS
*-------------------------------------------------------
*---ENEMY TURN (QUEST PROGRESS)--------------------------
*------------------------------------------------------- 
ENEMY_TURN:
    BSR     ENDL
    BSR     DECORATE
    LEA     GAMEPLAY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0
    TRAP    #15
    SUB.B   #49,(A4)
    CMP     #1,(A2)            IF ENEMY HEALTH IS BELOW 1, PLAYER WINS
    BLT WIN_FIGHT
    CMP     #1,(A4)             IF PLAYER HEALTH IS BELOW 1, PLAYER LOSES
    BLT     LOSE_FIGHT
    BSR     DECORATE
    BSR     PLAYER_TURN
    RTS

*-------------------------------------------------------
*-----------------------ATTACKING THE RABBIT------------------
* DEALS DAMAGE AND CHECKS IF PLAYER OR RABBIT ARE LOW
*-------------------------------------------------------
COLLISION:
    *HIT
    LEA     HIT_MSG,A1
    MOVE    #14,D0
    TRAP    #15
    BSR     DECORATE
    BSR     ENDL
    MOVE.B  #DAMAGE,D5
    MULU    #OWNED_WEAPONS,D5           MULTIPLIES DAMAGE BY LEVEL OF WEAPON
    SUB.B   D5,(A2)
    CMP     #1,(A2)
    BLT WIN_FIGHT
    CMP     #1,(A4)
    BLT     LOSE_FIGHT
    LEA     SHOW_ENEMY_HEALTH,A1
    MOVE    #14,D0
    TRAP    #15
    MOVE.B  (A2),D1
    MOVE.B  #3,D0
    TRAP    #15
    BSR     ENDL
    CMP     #1,(A2)
    BLT WIN_FIGHT
    CMP     #1,(A4)
    BLT     LOSE_FIGHT
    
    BSR ENEMY_TURN
    RTS
*The Win Screen
WIN_FIGHT:
    BSR     SHOW_HEALTH     Displays health on screen
    ADD.B   #25,(A6)        Gives the player money for defeating rabbit
    BSR     MONEY           Displays money on screen
    BSR     ENDL
    LEA     WIN_MSG,A1      Shows win message
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #100,(A4)       Replenishes player health
    MOVE.B  #80,(A2)        Replenishes rabbit health
    BSR REPLAY
    RTS
*The Lose screen  
LOSE_FIGHT:
    LEA     LOSE_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #100,(A4)
    BSR REPLAY
    RTS

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
    BSR     INPUT

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
    BNE     NEXT_ITEM   IF OPTION 1 NOT CHOSEN, MOVES TO OPTION 2
    
    MOVE.B  #POTION_PRICE,D4
    MOVE.B  (A6),D6
    CMP     D4,D6
    BGE     ADD_POTION  IF MONEY IS GREATER OR EQUAL TO PRICE OF POTION,CAN BUY
    LEA     NO_MONEY,A1
    MOVE.B  #14,D0
    TRAP    #15
    LEA     PRESS_ENTER,A1
    MOVE.B  #14,D0 
    TRAP    #15
    MOVE.B  #4,D0
    TRAP    #15
    BSR     MONEY   
    BSR     POTIONS
    BSR     WEAPONS
    BSR     SHOP_ASK
    RTS
ADD_POTION:
    ADD.B   #1,(A3)
    SUB.B   #POTION_PRICE,(A6)
    BSR     ENDL
    BSR     MONEY
    BSR     POTIONS
    BSR     WEAPONS
    BSR     ENDL
    BSR     SHOP_ASK
    RTS
 NEXT_ITEM:
    CMP     #2,D1
    BNE     GAME
    
    MOVE.B  #WEAPON_PRICE,D5
    MOVE.B  (A6),D6
    MOVE.B  (A5),D4
    CMP     #MAX_WEAPON,D4
    BEQ    CANT_ADD  IF MONEY IS EQUAL TO MAX NUMBER OF UPGRADES, CAN'T BUY
    CMP     D5,D6
    BGE     ADD_WEAPON  IF MONEY IS GREATER OR EQUAL TO PRICE OF WEAPON,CAN BUY
    LEA     NO_MONEY,A1
    MOVE.B  #14,D0
    TRAP    #15
    LEA     PRESS_ENTER,A1
    MOVE.B  #14,D0 
    TRAP    #15
    MOVE.B  #4,D0
    TRAP    #15
    BSR     MONEY
    BSR     POTIONS
    BSR     WEAPONS
    BSR     SHOP_ASK
    RTS
    
ADD_WEAPON:
    ADD.B   #1,(A5)
    SUB.B   #WEAPON_PRICE,(A6)
    BSR     ENDL
    BSR     MONEY
    BSR     POTIONS
    BSR     WEAPONS
    BSR     ENDL
    BSR     SHOP_ASK

    RTS

CANT_ADD:
    LEA MAX_UPGRADE,A1
    MOVE.B  #14,D0 
    TRAP    #15
    BSR SHOP_ASK
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
MONEY_MSG:      DC.B    'Money:',0
GAMEPLAY_MSG:   DC.B    'Rabbit has struck!',0
MISSION_MSG:    DC.B    'A new challenger has appeared...oh Gods no...'
                DC.B    $0D,$0A
                DC.B    'Eliminate the rabbit!',0
PLAYERTURN_MSG: DC.B    'What do you want to do?'
                DC.B    $0D,$0A
                DC.B    '1 - Attack!  2 - Heal thyself!'
                DC.B    $0D,$0A,0
HIT_MSG:        DC.B    'You lunged at the Rabbit!',0
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
                DC.B    'Sword Upgrade- 100'
                DC.B    $0D,$0A
                DC.B    '************************************************************'
                DC.B    $0D,$0A
                DC.B    '1 - Buy a Health Potion, 2 - Buy a weapon upgrade, Enter - Proceed'
                DC.B    $0D,$0A,0
NO_MONEY:       DC.B    $0D,$0A
                DC.B    'Not enough money to purchase item'
                DC.B    $0D,$0A,0
NOT_CORRECT:    DC.B    $0D,$0A
                DC.B    'Option Unavailable'
                DC.B    $0D,$0A,0
                
FULL_HEALTH:    DC.B    $0D,$0A
                DC.B    'HEALTH IS FULL - Unable to heal'
                DC.B    $0D,$0A,0

USE_POTION:     DC.B    $0D,$0A
                DC.B    'You have gained 60 health'
                DC.B    $0D,$0A,0
HEALTH_MSG:     DC.B    'Health:',0
ZEROPOTION_MSG: DC.B    'No potions available',0
SHOW_ENEMY_HEALTH: DC.B    'Enemy Health:',0
LOSE_MSG:       DC.B    'You Lose!',0
WIN_MSG:        DC.B    'You Win!',0
MAX_UPGRADE:    DC.B    'Weapon is at max level'
                DC.B    $0D,$0A
                DC.B    $0D,$0A,0


                

    END START











*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
