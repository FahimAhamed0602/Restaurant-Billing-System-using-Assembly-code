.MODEL SMALL
.STACK 100H
.DATA
    ; TEXTS
    s1 DB 10,13,"                *** Welcome to Restaurant Billing System ***$"
    st DB 10,13,"                        Press 1 to start$"
    foodmenu DB 10,13,"                *** Restaurant Food Menu ***$"
    ordereditem DB 10,13,"                Ordered Item: $"
    quantityprompt DB 10,13,"                Enter Quantity: $"
    billstring DB 10,13,"                Total Bill: Tk. $" ; Include Tk.
    foodorder DB 10,13,"                Order Foods: 1/2/3/4/5/6/7/9$"
    thank DB 10,13, "                *** Thank you for your order! ***$"
    input DB 10,13,"                Please enter your input: $"
    validinput DB 10,13,"                Please enter a valid input: $"
    break DB 10,13,"$"

    ; FOOD DETAILS 
    f1 DB 10,13,"                1. Chicken Fry          = Tk 100$"
    f2 DB 10,13,"                2. Burger                = Tk 200$"
    f3 DB 10,13,"                3. Shwarma               = Tk 90$"
    f4 DB 10,13,"                4. Salad                 = Tk 50$"
    f5 DB 10,13,"                5. Sandwich              = Tk 60$"
    f6 DB 10,13,"                6. Juice                 = Tk 50$"
    f7 DB 10,13,"                7. French Fry            = Tk 80$"
    done DB 10,13, "                9. Finish your order request$"
    reset DB 10,13,"                8. Reset your orders$"

    ; VARIABLES
    bill DW 0
    quantity DB 0
    itemprice DW 0
    totalbill DW 0

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

start:
    MOV totalbill, 0
    LEA DX, s1
    CALL print
    LEA DX, st
    CALL print

    LEA DX, input
    CALL print

    MOV AH, 1
    INT 21H

    CMP AL, '1'
    JNE invalid
    JE fooddtls

invalid:
    LEA DX, validinput
    CALL print
    JMP start

fooddtls:
    LEA DX, foodmenu
    CALL print
    LEA DX, f1
    CALL print
    LEA DX, f2
    CALL print
    LEA DX, f3
    CALL print
    LEA DX, f4
    CALL print
    LEA DX, f5
    CALL print
    LEA DX, f6
    CALL print
    LEA DX, f7
    CALL print
    LEA DX, reset
    CALL print
    LEA DX, done
    CALL print

foodorder_input:
    LEA DX, foodorder
    CALL print
    LEA DX, input
    CALL print

validate:
    MOV AH, 1
    INT 21H

    CMP AL, '1'
    JE order1
    CMP AL, '2'
    JE order2
    CMP AL, '3'
    JE order3
    CMP AL, '4'
    JE order4
    CMP AL, '5'
    JE order5
    CMP AL, '6'
    JE order6
    CMP AL, '7'
    JE order7
    CMP AL, '8'
    JE start ; Reset
    CMP AL, '9'
    JE finish

    LEA DX, validinput
    CALL print
    JMP foodorder_input

order1: MOV itemprice, 100
    JMP processorder
order2: MOV itemprice, 200
    JMP processorder
order3: MOV itemprice, 90
    JMP processorder
order4: MOV itemprice, 50
    JMP processorder
order5: MOV itemprice, 60
    JMP processorder
order6: MOV itemprice, 50
    JMP processorder
order7: MOV itemprice, 80
    JMP processorder

processorder:
    LEA DX, quantityprompt
    CALL print

    MOV AH, 1
    INT 21H
    SUB AL, '0'
    MOV quantity, AL

    MOV AX, itemprice
    MOV BL, quantity
    MUL BL
    ADD totalbill, AX

    LEA DX, billstring
    CALL print
    CALL showbill

    JMP fooddtls

finish:
    LEA DX, billstring
    CALL print
    CALL showbill
    LEA DX, thank
    CALL print

    MOV AX, 4C00H
    INT 21H

print PROC
    MOV AH, 09H
    INT 21H
    RET
print ENDP

showbill PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    MOV AX, totalbill
    CMP AX, 1000      ; Check if we need a comma
    JL no_comma

    ; Handle thousands place
    MOV BX, AX        ; Copy totalbill to BX
    MOV CX, 1000
    XOR DX, DX        ; Clear DX for division
    DIV CX          ; AX = thousands, DX = remainder
    PUSH DX         ; Push remainder for later

    ; Print thousands
    MOV CX, 10
    XOR BX, BX
show_thousands_digits:
    XOR DX, DX
    DIV CX
    PUSH DX
    INC BX
    CMP AX, 0
    JNE show_thousands_digits

display_thousands_digits:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    DEC BX
    JNZ display_thousands_digits

    MOV DL, ','       ; Print the comma
    MOV AH, 02H
    INT 21H

    POP AX         ; Restore the remainder (less than 1000)

no_comma:
    MOV CX, 10
    XOR BX, BX
show_digits:
    XOR DX, DX
    DIV CX
    PUSH DX
    INC BX
    CMP AX, 0
    JNE show_digits

display_digits:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    DEC BX
    JNZ display_digits

    POP DX
    POP CX
    POP BX
    POP AX
    RET
showbill ENDP

END MAIN