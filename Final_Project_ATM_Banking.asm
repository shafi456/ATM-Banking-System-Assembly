.MODEL SMALL
.STACK 100h

.DATA
    ; Account data
    IDs             DW 11, 22, 33
    PINs            DW 1111, 2222, 3333
    BALANCE         DW 10000, 5000, 2000
    accounts_count  DW 3
    TR_MAX          DW 5

    ; Transaction history
    tr_type         DW 0, 0, 0, 0, 0    ; 1=Deposit, 2=Withdraw, 3=Transfer
    tr_from         DW 0, 0, 0, 0, 0    ; Sender ID (for transfers) or account ID
    tr_recv         DW 0, 0, 0, 0, 0    ; Receiver ID (for transfers)
    tr_amt          DW 0, 0, 0, 0, 0    ; Transaction amount
    tr_count        DW 0

    ; Input variables
    input_id        DW 0
    input_pin       DW 0
    receiver_id     DW 0
    amount          DW 0
    user_index      DW 0

    ; Messages
    msg_enter_id            DB 'Enter the ID: $'
    msg_enter_pin           DB 'Enter the PIN: $'
    msg_invalid_id          DB 'ID is not in ATM account$'
    msg_incorrect_pin       DB 'Incorrect Password$'
    msg_login_success       DB 'Login Successful$'
    msg_welcome             DB 'Welcome to the Account: $'

    msg_menu1               DB '1. Show Balance$'
    msg_menu2               DB '2. Deposit$'
    msg_menu3               DB '3. Withdraw$'
    msg_menu4               DB '4. Balance Transfer$'
    msg_menu5               DB '5. Transaction History$'
    msg_menu6               DB '6. Logout$'
    msg_menu7               DB '7. Exit$'
    msg_select              DB 'select where to go: $'

    msg_balance             DB 'Your Current Balance is: $'
    msg_exit                DB 'Exit$'
    msg_processing          DB 'Still processing$'

    msg_enter_receiver      DB 'Enter where to send money: $'
    msg_enter_amount        DB 'Enter the amount you want to send: $'
    msg_insufficient        DB 'Insufficient Balance$'
    msg_transfer_success    DB 'Transfer Successful$'
    msg_next_step           DB 'Enter your next step:$'
    msg_stay                DB '1. to Stay and continue Transfer$'
    msg_back                DB '2. to go back$'
    msg_exit2               DB '3. Exit$'

    ; Deposit messages
    msg_deposit_title       DB 'Deposit:$'
    msg_enter_deposit       DB 'Deposit: $'
    msg_deposit_ok          DB 'Deposit Successful$'
    msg_deposit_menu        DB '1. Go Back  2. Exit$'

    ; Withdraw messages
    msg_enter_withdraw      DB 'Enter amount to withdraw: $'
    msg_withdraw_ok         DB 'Withdraw Successful$'
    msg_withdraw_menu       DB '1. Go Back  2. Exit$'

    ; History messages
    msg_history_title       DB '===== Transaction History =====$'
    msg_no_history          DB 'No transactions yet$'
    msg_deposit_label       DB 'DEPOSIT:    Amount: $'
    msg_withdraw_label      DB 'WITHDRAW:   Amount: $'
    msg_transfer_label      DB 'TRANSFER:   From: $'
    msg_to_label            DB ' To: $'
    msg_amount_label        DB ' Amount: $'
    msg_history_menu        DB '1. Go Back  2. Exit$'
    msg_transaction         DB 'Transaction #$'

    ; Balance menu messages
    msg_balance_menu1       DB '1. to go back$'
    msg_balance_menu2       DB '2. Exit$'
    msg_enter_value         DB 'Enter_Value: $'

    newline                 DB 0Dh, 0Ah, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

START_LOGIN:
    ; Enter ID
    LEA DX, msg_enter_id
    CALL PRINT_STRING
    CALL READ_NUMBER
    MOV input_id, AX
    CALL PRINT_NEWLINE

    ; Enter PIN
    LEA DX, msg_enter_pin
    CALL PRINT_STRING
    CALL READ_NUMBER
    MOV input_pin, AX
    CALL PRINT_NEWLINE

    ; Login
    CALL LOGIN

    ; Exit program
    MOV AH, 4Ch
    INT 21h
MAIN ENDP

; Input: input_id
; Output: AX = index or -1
FIND_ACCOUNT_BY_ID PROC
    PUSH BX
    PUSH CX
    PUSH SI

    MOV CX, accounts_count
    MOV SI, 0
    MOV BX, input_id

FIND_LOOP:
    CMP CX, 0
    JE FIND_NOT_FOUND

    MOV AX, IDs[SI]
    CMP AX, BX
    JE FIND_FOUND

    ADD SI, 2
    DEC CX
    JMP FIND_LOOP

FIND_FOUND:
    SHR SI, 1
    MOV AX, SI
    JMP FIND_END

FIND_NOT_FOUND:
    MOV AX, -1

FIND_END:
    POP SI
    POP CX
    POP BX
    RET
FIND_ACCOUNT_BY_ID ENDP

LOGIN PROC
    PUSH AX
    PUSH BX
    PUSH SI

    CALL FIND_ACCOUNT_BY_ID
    MOV user_index, AX

    CMP AX, -1
    JNE CHECK_PIN

    ; Invalid ID
    LEA DX, msg_invalid_id
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP LOGIN_END

CHECK_PIN:
    ; Check PIN
    MOV SI, AX
    SHL SI, 1
    MOV BX, PINs[SI]
    CMP BX, input_pin
    JE LOGIN_SUCCESS

    ; Incorrect PIN
    LEA DX, msg_incorrect_pin
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP LOGIN_END

LOGIN_SUCCESS:
    LEA DX, msg_login_success
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_welcome
    CALL PRINT_STRING
    MOV AX, input_id
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE

    ; Menu
    LEA DX, msg_menu1
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_menu2
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_menu3
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_menu4
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_menu5
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_menu6
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_menu7
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    ; Selection
    LEA DX, msg_select
    CALL PRINT_STRING

    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    CALL PRINT_NEWLINE

    CMP AL, 1
    JE DO_SHOW_BALANCE

    CMP AL, 2
    JE DO_DEPOSIT

    CMP AL, 3
    JE DO_WITHDRAW

    CMP AL, 4
    JE DO_TRANSFER

    CMP AL, 5
    JE DO_HISTORY

    CMP AL, 6
    JE DO_LOGOUT

    CMP AL, 7
    JE DO_EXIT

    ; Not implemented
    LEA DX, msg_processing
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP LOGIN_END

DO_SHOW_BALANCE:
    CALL SHOW_BALANCE_PROC
    JMP LOGIN_END

DO_DEPOSIT:
    CALL DEPOSIT_PROC
    JMP LOGIN_END

DO_WITHDRAW:
    CALL WITHDRAW_PROC
    JMP LOGIN_END

DO_TRANSFER:
    CALL BALANCE_TRANSFER
    JMP LOGIN_END

DO_HISTORY:
    CALL SHOW_HISTORY
    JMP LOGIN_END

DO_LOGOUT:
    CALL LOGOUT_PROC
    JMP LOGIN_END

DO_EXIT:
    LEA DX, msg_exit
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

LOGIN_END:
    POP SI
    POP BX
    POP AX
    RET
LOGIN ENDP

; Show Balance with menu
SHOW_BALANCE_PROC PROC
    PUSH AX
    PUSH SI

    MOV SI, user_index
    SHL SI, 1
    MOV AX, BALANCE[SI]

    LEA DX, msg_balance
    CALL PRINT_STRING
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE

    ; Show menu
    LEA DX, msg_next_step
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_balance_menu1
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_balance_menu2
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_enter_value
    CALL PRINT_STRING

    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    CALL PRINT_NEWLINE

    CMP AL, 1
    JE BALANCE_GO_BACK

    ; Exit
    LEA DX, msg_exit
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP BALANCE_DONE

BALANCE_GO_BACK:
    CALL LOGIN

BALANCE_DONE:
    POP SI
    POP AX
    RET
SHOW_BALANCE_PROC ENDP

; Logout procedure
LOGOUT_PROC PROC
    PUSH AX

    ; Reset all global variables
    MOV input_id, 0
    MOV input_pin, 0
    MOV receiver_id, 0
    MOV amount, 0
    MOV user_index, 0

    ; Return to main login
    POP AX
    
    ; Jump back to start
    JMP START_LOGIN
    
    RET
LOGOUT_PROC ENDP

; Add transaction to history
; Input: BX = type (1=Deposit, 2=Withdraw, 3=Transfer)
;        CX = from_id
;        DX = to_id (for transfer)
;        amount = amount
ADD_TRANSACTION PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    ; Check if history is full
    MOV AX, tr_count
    CMP AX, TR_MAX
    JGE SHIFT_HISTORY

    ; Add new transaction
    JMP ADD_NEW_TRANS

SHIFT_HISTORY:
    ; Shift all transactions left (remove oldest)
    MOV SI, 0
    MOV CX, 4

SHIFT_LOOP:
    MOV AX, tr_type[SI+2]
    MOV tr_type[SI], AX
    MOV AX, tr_from[SI+2]
    MOV tr_from[SI], AX
    MOV AX, tr_recv[SI+2]
    MOV tr_recv[SI], AX
    MOV AX, tr_amt[SI+2]
    MOV tr_amt[SI], AX
    ADD SI, 2
    LOOP SHIFT_LOOP

    ; Decrement count to make room
    DEC tr_count

ADD_NEW_TRANS:
    ; Get position for new transaction
    MOV AX, tr_count
    MOV SI, AX
    SHL SI, 1

    ; Store transaction
    MOV tr_type[SI], BX
    MOV tr_from[SI], CX
    MOV tr_recv[SI], DX
    MOV AX, amount
    MOV tr_amt[SI], AX

    ; Increment count
    INC tr_count

    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
ADD_TRANSACTION ENDP

DEPOSIT_PROC PROC
    PUSH AX
    PUSH BX
    PUSH SI

    ; Show Deposit title
    LEA DX, msg_deposit_title
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    ; Take deposit amount
    LEA DX, msg_enter_deposit
    CALL PRINT_STRING
    CALL READ_NUMBER
    MOV amount, AX
    CALL PRINT_NEWLINE

    ; Update balance
    MOV SI, user_index
    SHL SI, 1
    MOV AX, amount
    ADD BALANCE[SI], AX

    ; Add to history (type=1 for Deposit)
    MOV BX, 1
    MOV CX, input_id
    MOV DX, 0
    CALL ADD_TRANSACTION

    ; Success
    LEA DX, msg_deposit_ok
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    ; Show updated balance
    MOV AX, BALANCE[SI]
    LEA DX, msg_balance
    CALL PRINT_STRING
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE

    ; Go back / Exit
    LEA DX, msg_deposit_menu
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    CALL PRINT_NEWLINE

    CMP AL, 1
    JE DEPOSIT_GO_BACK

    ; Exit
    LEA DX, msg_exit
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP DEPOSIT_DONE

DEPOSIT_GO_BACK:
    CALL LOGIN

DEPOSIT_DONE:
    POP SI
    POP BX
    POP AX
    RET
DEPOSIT_PROC ENDP

BALANCE_TRANSFER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI

    ; Receiver ID
    LEA DX, msg_enter_receiver
    CALL PRINT_STRING
    CALL READ_NUMBER
    MOV receiver_id, AX
    CALL PRINT_NEWLINE

    ; Amount
    LEA DX, msg_enter_amount
    CALL PRINT_STRING
    CALL READ_NUMBER
    MOV amount, AX
    CALL PRINT_NEWLINE

    ; Sender balance
    MOV SI, user_index
    SHL SI, 1
    MOV BX, BALANCE[SI]

    ; Check sufficient balance
    CMP BX, AX
    JG TRANSFER_OK

    LEA DX, msg_insufficient
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP TRANSFER_END

TRANSFER_OK:
    ; Deduct from sender
    MOV SI, user_index
    SHL SI, 1
    MOV AX, amount
    SUB BALANCE[SI], AX

    ; Find receiver and add
    MOV CX, accounts_count
    MOV SI, 0

FIND_RECEIVER:
    CMP CX, 0
    JE TRANSFER_COMPLETE

    MOV AX, IDs[SI]
    CMP AX, receiver_id
    JE ADD_TO_RECEIVER

    ADD SI, 2
    DEC CX
    JMP FIND_RECEIVER

ADD_TO_RECEIVER:
    MOV AX, amount
    ADD BALANCE[SI], AX

TRANSFER_COMPLETE:
    ; Add to history (type=3 for Transfer)
    MOV BX, 3
    MOV CX, input_id
    MOV DX, receiver_id
    CALL ADD_TRANSACTION

    LEA DX, msg_transfer_success
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    ; Next step
    LEA DX, msg_next_step
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_stay
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_back
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    LEA DX, msg_exit2
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    CALL PRINT_NEWLINE

    CMP AL, 1
    JE STAY_TRANSFER

    CMP AL, 2
    JE GO_BACK

    JMP TRANSFER_END

STAY_TRANSFER:
    CALL BALANCE_TRANSFER
    JMP TRANSFER_END

GO_BACK:
    CALL LOGIN

TRANSFER_END:
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
BALANCE_TRANSFER ENDP

WITHDRAW_PROC PROC
    PUSH AX
    PUSH BX
    PUSH SI

    ; Withdraw amount
    LEA DX, msg_enter_withdraw
    CALL PRINT_STRING
    CALL READ_NUMBER
    MOV amount, AX
    CALL PRINT_NEWLINE

    ; Current balance
    MOV SI, user_index
    SHL SI, 1
    MOV BX, BALANCE[SI]

    ; Check balance
    CMP BX, amount
    JB WITHDRAW_INSUFFICIENT

    ; Update balance
    MOV AX, amount
    SUB BALANCE[SI], AX

    ; Add to history (type=2 for Withdraw)
    MOV BX, 2
    MOV CX, input_id
    MOV DX, 0
    CALL ADD_TRANSACTION

    LEA DX, msg_withdraw_ok
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP WITHDRAW_MENU

WITHDRAW_INSUFFICIENT:
    LEA DX, msg_insufficient
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

WITHDRAW_MENU:
    LEA DX, msg_withdraw_menu
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    CALL PRINT_NEWLINE

    CMP AL, 1
    JE WITHDRAW_GO_BACK

    LEA DX, msg_exit
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP WITHDRAW_DONE

WITHDRAW_GO_BACK:
    CALL LOGIN

WITHDRAW_DONE:
    POP SI
    POP BX
    POP AX
    RET
WITHDRAW_PROC ENDP

SHOW_HISTORY PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    ; Title
    LEA DX, msg_history_title
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    ; Check if empty
    MOV AX, tr_count
    CMP AX, 0
    JNE DISPLAY_HISTORY

    LEA DX, msg_no_history
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP HISTORY_MENU

DISPLAY_HISTORY:
    MOV CX, tr_count
    MOV SI, 0

HISTORY_LOOP:
    PUSH CX

    ; Transaction number
    LEA DX, msg_transaction
    CALL PRINT_STRING
    MOV AX, tr_count
    SUB AX, CX
    INC AX
    CALL PRINT_NUMBER
    LEA DX, newline
    CALL PRINT_STRING

    ; Check type
    MOV BX, tr_type[SI]
    
    CMP BX, 1
    JE SHOW_DEPOSIT
    
    CMP BX, 2
    JE SHOW_WITHDRAW
    
    CMP BX, 3
    JE SHOW_TRANSFER
    
    JMP NEXT_TRANS

SHOW_DEPOSIT:
    LEA DX, msg_deposit_label
    CALL PRINT_STRING
    MOV AX, tr_amt[SI]
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE
    JMP NEXT_TRANS

SHOW_WITHDRAW:
    LEA DX, msg_withdraw_label
    CALL PRINT_STRING
    MOV AX, tr_amt[SI]
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE
    JMP NEXT_TRANS

SHOW_TRANSFER:
    LEA DX, msg_transfer_label
    CALL PRINT_STRING
    MOV AX, tr_from[SI]
    CALL PRINT_NUMBER
    
    LEA DX, msg_to_label
    CALL PRINT_STRING
    MOV AX, tr_recv[SI]
    CALL PRINT_NUMBER
    
    LEA DX, msg_amount_label
    CALL PRINT_STRING
    MOV AX, tr_amt[SI]
    CALL PRINT_NUMBER
    CALL PRINT_NEWLINE

NEXT_TRANS:
    ADD SI, 2
    POP CX
    LOOP HISTORY_LOOP

HISTORY_MENU:
    LEA DX, msg_history_menu
    CALL PRINT_STRING
    CALL PRINT_NEWLINE

    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    CALL PRINT_NEWLINE

    CMP AL, 1
    JE HISTORY_GO_BACK

    LEA DX, msg_exit
    CALL PRINT_STRING
    CALL PRINT_NEWLINE
    JMP HISTORY_DONE

HISTORY_GO_BACK:
    CALL LOGIN

HISTORY_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
SHOW_HISTORY ENDP

PRINT_STRING PROC
    PUSH AX
    MOV AH, 09h
    INT 21h
    POP AX
    RET
PRINT_STRING ENDP

PRINT_NEWLINE PROC
    PUSH DX
    LEA DX, newline
    CALL PRINT_STRING
    POP DX
    RET
PRINT_NEWLINE ENDP

; Output: AX = number
READ_NUMBER PROC
    PUSH BX
    PUSH CX
    PUSH DX

    XOR BX, BX
    XOR CX, CX

READ_DIGIT:
    MOV AH, 01h
    INT 21h

    CMP AL, 0Dh
    JE READ_DONE

    SUB AL, '0'
    MOV CL, AL

    MOV AX, BX
    MOV DX, 10
    MUL DX
    ADD AX, CX
    MOV BX, AX

    JMP READ_DIGIT

READ_DONE:
    MOV AX, BX

    POP DX
    POP CX
    POP BX
    RET
READ_NUMBER ENDP

; Input: AX = number
PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV CX, 0
    MOV BX, 10

DIVIDE_LOOP:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX

    CMP AX, 0
    JNE DIVIDE_LOOP

PRINT_LOOP:
    POP DX
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    LOOP PRINT_LOOP

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP

END MAIN