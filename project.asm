[org 0x0100]
jmp start

instruction1: db 'Enter the cave file name or press Enter to use the default (cave1.txt) $'
input_tag: db 10, 13, 'File name: $'
instruction5: db 10, 13, 'Opening file now... $'
error_tag1: db 10, 13, 'Could not open the input file $'
error_tag2: db 10, 13, 'Program will now quit $'
instruction6: db 10, 13, 'Done $'
instruction2: db 10, 13, 'Press any key to load the game... $'
GameName_tag: db 'BOULDER DASH', 0
instruction3: db 'Arrows keys: move', 0
instruction4: db 'Esc: quit', 0
instruction7: db 'F2: restart', 0
UserInput_buffer: times 80 db 0 
file_name: db 'cave1.txt $'
file_handler: dw 0
buffer: times 1600 db 0
str1: db 'Score: ', 0
score_count: dw 0
str2: db 'Level: ', 0
level_count: db '1', 0
GameEnd_tag: db 'GAME ENDED', 0
error_tag3: db 10, 13, 'Incomplete Data in the file $'
location: dw 0
oldIsr: dd 0
GameOver_tag: db '    GAME OVER!!!     ', 0
LvlComplete_tag: db '  LEVEL COMPLETED  ', 0
sound_note: db 7,'$'

;--------------------------------------------------------------
;SUBROUTINE FOR CLEAR SCREEN
;--------------------------------------------------------------
clrscr:
push es 
push ax 
push cx 
push di 

mov ax, 0xb800  
mov es, ax      ;point es to video base
xor di, di      ;point di to top left
mov ax, 0x0720  ;space char in normal attribute
mov cx, 2000    ;number of screen locations
cld             ;auto increment mode
rep stosw       ;clear the whole screen

pop di
pop cx
pop ax
pop es 
ret

;--------------------------------------------------------------
;SUBROUTINE FOR PRINT STRING
;--------------------------------------------------------------
printstr:
push bp
mov bp, sp
push es
push ax
push cx
push si
push di

push ds           
pop es
mov di, [bp+4]
mov cx, 0xffff   ;load maximum number in cx
xor al, al       ;load a zero in al
repne scasb      ;find zero in the string
mov ax, 0xffff   ;load maximum number in ax
sub ax, cx       ;find change in cx
dec ax           ;exclude null from length
jz exit          ;no printing if string is empty

mov cx, ax       ;load string length in cx
mov ax, 0xb800
mov es, ax       ;point es to video base
mov al, 80       ;load al with colums per row
mul byte[bp+8]   ;multiply with y position
add ax, [bp+10]  ;add x position
shl ax, 1        ;turn into byte offset
mov di, ax       ;point di to required location
mov si, [bp+4]   ;point si to string
mov ah, [bp+6]   ;load attribute in ah
cld              ;auto increment mode
nextchar1:
lodsb            ;load next char in al
stosw            ;print char/attribute pair
loop nextchar1   ;repeat the whole string
exit:
pop di
pop si
pop cx
pop ax
pop es
pop bp
ret 8

;--------------------------------------------------------------
;SUBROUTINE FOR INTERFACE PRINTING
;--------------------------------------------------------------
interface_print:
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si
push di

;print a whole row with the ascii of wall
mov cx, ax
mov ax, 0xb800
mov es, ax
mov di, 320
mov ax, 0x66db
mov cx, 80
cld
rep stosw

mov dx, [bp+4]  ;total rows of text file
mov si, 0
jmp repeat

l1:
jmp last2

repeat:
sub dx, 1
cmp dx, 0
jl l1
mov cx, [bp+6]   ;total columns of text file
mov word[es:di], 0x66db  ;print the first column of each row with wall
add di, 2   ;move onto the next video memory location

;compare the value in buffer with the specific letters
;if it is one of those then go on to print the desired ascii associated with it
;else if it does not match then move onto the next value in buffer
again:
mov al, [buffer+si]
cmp al, 'x'
je next1
cmp al, 'R'
je next2
cmp al, 'T'
je next3
cmp al, 'B'
je next4
cmp al, 'D'
je next5
cmp al, 'W'
je next6
inc si
jmp again

next1:
mov word[es:di], 0x70b1 ;print at the current video memory location
add di, 2               ;mov the pointer onto the next video memory location
sub cx, 1               ;sub the column number so that we know when a whole row is complete
jz last                 ;if cx is zero then we know that the row is completed
inc si                  ;if not zero then move onto the next value in buffer
jmp again               ;then check for that value 

next2:
mov word[es:di], 0x0F02 ;print at the current video memory location
mov word[location], di  ;save the location of rockford for movement later in location variable
add di, 2               ;mov the pointer onto the next video memory location
sub cx, 1               ;sub the column number so that we know when a whole row is complete
jz last                 ;if cx is zero then we know that the row is completed
inc si                  ;if not zero then move onto the next value in buffer
jmp again               ;then check for that value 

next3:
mov word[es:di], 0x0A7f ;print at the current video memory location
add di, 2               ;mov the pointer onto the next video memory location
sub cx, 1               ;sub the column number so that we know when a whole row is complete
jz last                 ;if cx is zero then we know that the row is completed
inc si                  ;if not zero then move onto the next value in buffer
jmp again               ;then check for that value 

next4:
mov word[es:di], 0x0509 ;print at the current video memory location
add di, 2               ;mov the pointer onto the next video memory location
sub cx, 1               ;sub the column number so that we know when a whole row is complete
jz last                 ;if cx is zero then we know that the row is completed
inc si                  ;if not zero then move onto the next value in buffer
jmp again               ;then check for that value 

next5:
mov word[es:di], 0x0B04 ;print at the current video memory location
add di, 2               ;mov the pointer onto the next video memory location
sub cx, 1               ;sub the column number so that we know when a whole row is complete
jz last                 ;if cx is zero then we know that the row is completed
inc si                  ;if not zero then move onto the next value in buffer
jmp again               ;then check for that value 

next6:
mov word[es:di], 0x66db ;print at the current video memory location
add di, 2               ;mov the pointer onto the next video memory location
sub cx, 1               ;sub the column number so that we know when a whole row is complete
jz last                 ;if cx is zero then we know that the row is completed
inc si                  ;if not zero then move onto the next value in buffer
jmp again               ;then check for that value 
 
last: 
;print wall in the last column of each row
mov word[es:di], 0x66db
add di, 2
inc si
jmp repeat

last2:
;after the file has completely been read then print a wall in the last row
mov cx, ax
mov ax, 0xb800
mov es, ax
mov ax, 0x66db
mov cx, 80
cld
rep stosw

pop di
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 4
;--------------------------------------------------------------
;SUBROUTINE FOR FILE OPENING
;--------------------------------------------------------------
file_open:
push bp
mov bp, sp
push ax
push bx
push cx
push dx
push si

mov bx, [bp+4]   ;the address of the file moved to bx register

clc
mov ah, 3dh
mov dx, bx
mov al, 0
int 21h
mov [file_handler], ax     
jnc error_find

;those string are being printed which will tell that there is no file
mov dx, instruction5  
mov ah, 9
int 21h
mov dx, error_tag1  
mov ah, 9
int 21h
mov dx, error_tag2  
mov ah, 9
int 21h
mov word[bp+6], 0  ;0 is pushed onto the stack so that we can pop it in main and check wheter the game has to start or not(0=not start, 1=start)
jmp end2

error_find:
call file_read  ;if there is a file then go into the file read function

mov cx, 0    ;to count the number of elements in buffer to check to file size error
mov si, 0    ;to loop through the buffer by pointing towards the first element in the buffer
loop1:
cmp byte[buffer+si], 'x'  ;checking if the buffer contains the specific element
jne n2                    ;if not the check for the next element
inc cx                    ;if yes the increment the count for total elements in file
inc si                    ;and move onto the next value in buffer
jmp loop1                 ;then start the loop again by checking for the next value

n2:
cmp byte[buffer+si], 'R'  ;checking if the buffer contains the specific element
jne n3                    ;if not the check for the next element
inc cx                    ;if yes the increment the count for total elements in file
inc si                    ;and move onto the next value in buffer
jmp loop1                 ;then start the loop again by checking for the next value

n3:
cmp byte[buffer+si], 'T'  ;checking if the buffer contains the specific element
jne n4                    ;if not the check for the next element
inc cx                    ;if yes the increment the count for total elements in file
inc si                    ;and move onto the next value in buffer
jmp loop1                 ;then start the loop again by checking for the next value

n4:
cmp byte[buffer+si], 'B'  ;checking if the buffer contains the specific element
jne n5                    ;if not the check for the next element
inc cx                    ;if yes the increment the count for total elements in file
inc si                    ;and move onto the next value in buffer
jmp loop1                 ;then start the loop again by checking for the next value

n5:
cmp byte[buffer+si], 'D'  ;checking if the buffer contains the specific element
jne n6                    ;if not the check for the next element
inc cx                    ;if yes the increment the count for total elements in file
inc si                    ;and move onto the next value in buffer
jmp loop1                 ;then start the loop again by checking for the next value

n6:
cmp byte[buffer+si], 'W'  ;checking if the buffer contains the specific element
jne n7                    ;if not the check for the next element
inc cx                    ;if yes the increment the count for total elements in file
inc si                    ;and move onto the next value in buffer
jmp loop1                 ;then start the loop again by checking for the next value

n7:
cmp si, 1600  ;if the value of si is 1600 that means that whole file has to traversed
je find       ;if it is equal then go onto find further errors in the file
inc si        ;if not the move onto the next value in the buffer
jmp loop1     ;then start the loop again by checking for the next value

find:
cmp cx, 1560  
je no_error   ;if the total elements in the file were 1560 that means file size is perfect
;else print strings that tell for error
mov dx, instruction5  
mov ah, 9
int 21h
mov dx, error_tag3  
mov ah, 9
int 21h
mov dx, error_tag2  
mov ah, 9
int 21h
mov word[bp+6], 0 ;0 is pushed onto the stack so that we can pop it in main and check wheter the game has to start or not(0=not start, 1=start)
jmp end2

no_error:
;print strings that tell for no error
mov dx, instruction5  
mov ah, 9
int 21h
mov dx, instruction6 
mov ah, 9
int 21h
mov dx, instruction2
mov ah, 9
int 21h
mov word[bp+6], 1  ;1 is pushed onto the stack so that we can pop it in main and check wheter the game has to start or not(0=not start, 1=start)

end2:
pop si
pop dx
pop cx
pop bx
pop ax
pop bp
ret 2
;--------------------------------------------------------------
;SUBROUTINE FOR FILE READING
;--------------------------------------------------------------
file_read:
push bp
mov bp, sp
push ax
push bx
push cx
push dx

mov ah, 3fh
mov bx, [file_handler]
mov cx, 1600    ;the size of the file that has to be read
mov dx, buffer  ;read all the file into the buffer 
int 21h

pop dx
pop cx
pop bx
pop ax
pop bp
ret 

;--------------------------------------------------------------
;SUBROUTINE FOR FILE CLOSING
;--------------------------------------------------------------
file_close:
push bp
mov bp, sp
push ax
push bx
push cx
push dx

mov ah, 3eh
mov bx, [file_handler]
int 21h

pop dx
pop cx
pop bx
pop ax
pop bp
ret

;--------------------------------------------------------------
;SUBROUTINE FOR SCORE PRINTING
;--------------------------------------------------------------
score_print:
push ax
push bx
push cx
push di

mov cl, 0        ; counter for number of digits
mov ax, [score_count]
mov bx, 10       ; divisor
div_loop:
mov dx, 0        ; upper half of dividend is zero in our case
div bx           ; DX_AX / BX => remainder DX, quotient AX
push dx          
inc cl           ; counter++
cmp ax, 0        ; continue until quotient gets to zero
jne div_loop
    
    ; Now print those digits on stack, one at a time
    
mov di, 3854     ; video memory offset 
mov ah, 0x0F     ; attribute: white on black
                     
print_loop:          
pop bx           ; get the digit
mov al, bl       ; copy the digit to AL (being < 10 it fits in one byte)
add al, 0x30     ; convert digit to char   
mov [es:di], ax  ; print it
add di, 2        ; advance offset
dec cl           ; counter--
jnz print_loop

pop di
pop cx
pop bx
pop ax
ret
;--------------------------------------------------------------
;SUBROUTINE FOR UP
;--------------------------------------------------------------
up:
push ax
push bx
push cx
push di

mov ax, [location]
mov bx, ax
sub bx, 160
mov cx, bx
sub cx, 160

cmp1:
mov di, ax
cmp word[es:di], 0x8402   ;if rockfoued touches the boulder
jne cmp2
jmp up_end

cmp2:
mov di, ax
cmp word[es:di], 0x8202   ;if rocford reaches the target
jne cmp3
jmp up_end

cmp3:
mov di, cx
cmp byte[es:di], 0x09   ;if boulder
jne cmp4
mov word[es:di], 0x8409 
mov di, bx
cmp byte[es:di], 0x04   ;if diamond
jne skip1
add word[score_count], 1
call score_print
skip1:
mov word[location], di
mov word[es:di], 0x8402
mov di, ax
mov word[es:di], 0x0720
;printing of game over
push 0
push 1
push 0x0F
push GameOver_tag                 
call printstr
jmp up_end

cmp4:
mov di, bx
cmp byte[es:di], 0x04   ;if diamond
jne cmp5
mov word[es:di], 0x0F02
mov word[location], di
mov di, ax
mov word[es:di], 0x0720
add word[score_count], 1
call score_print
jmp up_end

cmp5:
mov di, bx
cmp byte[es:di], 0x7f   ;if target
jne cmp6
mov word[es:di], 0x8202
mov word[location], di
mov di, ax
mov word[es:di], 0x0720
;print of level completed
push 0
push 1
push 0x0F
push LvlComplete_tag                 
call printstr
jmp up_end

cmp6:
mov di, bx
cmp byte[es:di], 0xdb   ;if wall
jne cmp7
call sound
jmp up_end

cmp7:
mov di, bx
mov word[es:di], 0x0F02  ;if dirt
mov word[location], di
mov di, ax
mov word[es:di], 0x0720

up_end:
pop di
pop cx
pop bx
pop ax
ret
;--------------------------------------------------------------
;SUBROUTINE FOR DOWN
;--------------------------------------------------------------
down:
push ax
push bx
push di

mov ax, [location]
mov bx, ax
add bx, 160

cmp11:
mov di, ax
cmp word[es:di], 0x8402   ;if rockfoued touches the boulder
jne cmp12
jmp down_end

cmp12:
mov di, ax
cmp word[es:di], 0x8202   ;if rocford reaches the target
jne cmp13
jmp down_end

cmp13:
mov di, bx
cmp byte[es:di], 0x09   ;if boulder
jne cmp14
call sound
jmp down_end

cmp14:
mov di, bx
cmp byte[es:di], 0x04   ;if diamond
jne cmp15
mov word[es:di], 0x0F02
mov word[location], di
mov di, ax
mov word[es:di], 0x0720
add word[score_count], 1
call score_print
jmp down_end

cmp15: 
mov di, bx
cmp byte[es:di], 0x7f   ;if target
jne cmp16
mov word[es:di], 0x8202
mov word[location], di
mov di, ax
mov word[es:di], 0x0720
;print of level completed
push 0
push 1
push 0x0F
push LvlComplete_tag                 
call printstr
jmp down_end

cmp16:
mov di, bx
cmp byte[es:di], 0xdb   ;if wall
jne cmp17
call sound
jmp down_end

cmp17:
mov di, bx
mov word[es:di], 0x0F02   ;if dirt
mov word[location], di
mov di, ax
mov word[es:di], 0x0720

down_end:
pop di
pop bx
pop ax
ret

;--------------------------------------------------------------
;SUBROUTINE FOR RIGHT
;--------------------------------------------------------------
right:
push ax
push bx
push cs
push di

mov ax, [location]
mov bx, ax
add bx, 2
mov cx, bx
sub cx, 160

cmp21:
mov di, ax
cmp word[es:di], 0x8402   ;if rockfoued touches the boulder
jne cmp22
jmp right_end

cmp22:
mov di, ax
cmp word[es:di], 0x8202   ;if rocford touches the target
jne cmp23
jmp right_end

cmp23:
mov di, bx
cmp byte[es:di], 0x09   ;if boulder
jne cmp24
call sound
jmp right_end

cmp24:
mov di, cx
cmp byte[es:di], 0x09   ;if boulder above very you move right
jne cmp25
mov word[es:di], 0x8409   
mov di, bx
cmp byte[es:di], 0x04   ;if diamond
jne skip2
add word[score_count], 1
call score_print
skip2:
mov word[location], di
mov word[es:di], 0x8402
mov di, ax
mov word[es:di], 0x0720
push 0
push 1
push 0x0F
push GameOver_tag
call printstr
jmp right_end

cmp25:
mov di, bx
cmp byte[es:di], 0x04   ;if diamond
jne cmp26
mov word[es:di], 0x0F02
mov word[location], di
mov di, ax
mov word[es:di], 0x0720
add word[score_count], 1
call score_print
jmp right_end

cmp26: 
mov di, bx
cmp byte[es:di], 0x7f   ;if target
jne cmp27
mov word[es:di], 0x8202
mov word[location], di
mov di, ax
mov word[es:di], 0x0720
;print of level completed
push 0
push 1
push 0x0F
push LvlComplete_tag                 
call printstr
jmp right_end

cmp27:
mov di, bx
cmp byte[es:di], 0xdb   ;if wall
jne cmp28
call sound
jmp right_end

cmp28:
mov di, bx
mov word[es:di], 0x0F02
mov word[location], di
mov di, ax
mov word[es:di], 0x0720


right_end:
pop di
pop cx
pop bx
pop ax
ret
;--------------------------------------------------------------
;SUBROUTINE FOR LEFT
;--------------------------------------------------------------
left:
push ax
push bx
push cx
push di

mov ax, [location]
mov bx, ax
sub bx, 2
mov cx, bx
sub cx, 160

cmp31:
mov di, ax
cmp word[es:di], 0x8402   ;if rockfoued touches the boulder
jne cmp32
jmp left_end

cmp32:
mov di, ax
cmp word[es:di], 0x8202   ;if rocford reaches the target
jne cmp33
jmp left_end

cmp33:
mov di, bx
cmp byte[es:di], 0x09   ;if boulder
jne cmp34
call sound
jmp left_end

cmp34:
mov di, cx
cmp byte[es:di], 0x09   ;if boulder above very you move right
jne cmp35
mov word[es:di], 0x8409   
mov di, bx
cmp byte[es:di], 0x04   ;if diamond
jne skip3
add word[score_count], 1
call score_print
skip3:
mov word[location], di
mov word[es:di], 0x8402
mov di, ax
mov word[es:di], 0x0720
push 0
push 1
push 0x0F
push GameOver_tag
call printstr
jmp left_end

cmp35:
mov di, bx
cmp byte[es:di], 0x04   ;if diamond
jne cmp36
mov word[es:di], 0x0F02
mov word[location], di
mov di, ax
mov word[es:di], 0x0720
add word[score_count], 1
call score_print
jmp left_end

cmp36: 
mov di, bx
cmp byte[es:di], 0x7f   ;if target
jne cmp37
mov word[es:di], 0x8202
mov word[location], di
mov di, ax
mov word[es:di], 0x0720
;print of level completed
push 0
push 1
push 0x0F
push LvlComplete_tag                 
call printstr
jmp left_end

cmp37:
mov di, bx
cmp byte[es:di], 0xdb   ;if wall
jne cmp38
call sound
jmp left_end

cmp38:
mov di, bx
mov word[es:di], 0x0F02
mov word[location], di
mov di, ax
mov word[es:di], 0x0720


left_end:
pop di
pop cx
pop bx
pop ax
ret
;--------------------------------------------------------------
;SUBROUTINE FOR SOUND
;--------------------------------------------------------------
sound:	
push ax
push dx

mov ah, 02h  ; set cursor position service
mov dh, 0 ; row #
mov dl, 0 ; column #
mov bh, 0  ; first video page
int 10h

mov ah, 0eh
mov al, 7
mov bh, 0
mov bl, 07
int 10h

pop dx
pop ax
ret	
;--------------------------------------------------------------
;MAIN
;--------------------------------------------------------------
start:
call clrscr

mov ah, 02h  ; set cursor position service
mov dh, 0 ; row #
mov dl, 0 ; column #
mov bh, 0  ; first video page
int 10h

;print of str1
mov dx, instruction1   ;address of string 
mov ah, 9
int 21h

;print of input_tag and user input
mov dx, input_tag   ;address of string 
mov ah, 9
int 21h


mov ah, 01h
int 21h
cmp al, 13       ;if enter pressed without typing anything then open default file
je file
;if any other key is pressed then save that in the UserInput_buffer varible          
mov si, UserInput_buffer     
mov [si], al
inc si

nextchar:
;taking user input until enter is not pressed
mov ah, 01h
int 21h
cmp al, 13       
je check_file
mov [si], al     
inc si
loop nextchar

file:
;to open the default file
sub sp, 2          ; space created on stack for return
push file_name         ; file address pushed onto the stack
call file_open     ; subroutine for file opening called
pop ax             ; 1 returned through stack if file exists
cmp ax, 1        
je game_start      ; if 1 is returned through stack game starts
jmp terminate            ; else terminate the program

check_file:
;to open the file entered by the user
sub sp, 2          ; space created on stack for return
push UserInput_buffer          ; UserInput_buffer address pushed onto the stack
call file_open
pop ax             ; 1 returned through stack if file exists
cmp ax, 1
je game_start      ; if 1 is returned through stack game starts
jmp terminate            ; else terminate the program

game_start:
;waiting for any key to be pressed
mov ah, 01h
int 21h
mov ah, 00

restart:
mov word[score_count], 0
call clrscr

;print of GameName_tag
push 32      ;row number
push 0       ;column number
push 0x0F    ;attribute
push GameName_tag
call printstr

;print of restart
push 32       ;row number
push 1       ;column number
push 0x0F    ;attribute
push instruction7
call printstr

push 0       ;row number
push 1       ;column number
push 0x0F    ;attribute
push instruction3
call printstr

push 71      ;row number
push 1       ;column number
push 0x0F    ;attribute
push instruction4
call printstr

;cursor hiding 
mov ah, 01h
mov ch, 01
mov cl, 0
int 10h

;printing of interface
push 78  ; total columns of text file
push 20  ; total rows of text file
call interface_print

;score and level printing
push 0        ;row number
push 24       ;column number
push 0x0F     ;attribute
push str1
call printstr

call score_print

push 71       ;row number
push 24       ;column number
push 0x0F     ;attribute
push str2
call printstr

push 78       ;row number
push 24       ;column number
push 0x0F     ;attribute
push level_count
call printstr

again1:
;to exit the game if esc pressed
mov ah, 00h
int 16h
cmp ah, 72  ;up
jne compare1
call up
jmp again1
compare1:
cmp ah, 75  ;left
jne compare2
call left
jmp again1
compare2:
cmp ah, 80  ;down
jne compare3
call down
jmp again1
compare3:
cmp ah, 77  ;right
jne compare4
call right
jmp again1
compare4:
cmp ah, 60   ;restart
jne compare5
call restart
compare5:
cmp ah, 1    ;exit
jne again1



call clrscr

push 33       ;row number
push 12       ;column number
push 0x0F     ;attribute
push GameEnd_tag
call printstr

terminate:
;file closing
call file_close

mov ax, 0x4c00
int 21h