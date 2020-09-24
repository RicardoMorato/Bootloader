org 0x7e00
jmp 0x0000:start

data:
    tip1 db 'Eu dizer, malandro voce eh tosquinho, voce nao entende', 0
    tip2 db '  ISSO NA QUINTA SERIE PRIMARIA, JA DARIA PRA ENTENDER', 0
    tip3 db '    SE NAO O NEGO CAGA NA SUA CABECA, E VOCE NAO REAGE', 0
    tip db 'Dica ',0
    options1 db '(1) Responder      (2) Proxima dica' , 0
    options2 db '           (1) Responder' , 0
    msg db 'Digite a resposta: ', 0
    correct db 'Parabens! Voce tem brio ;)', 0
    wrong db 'Voce nao entende :/', 0
    str1 times 5 db 0
    str2 db 'brio',0
    flag db 0

clear:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x07
    mov bh, [bp+4]      
    mov al, 0x00               
    mov cx, 0x00        
    mov dh, 0x18        
    mov dl, 0x4f        
    int 0x10

    push word[bp+6]   
    call movecursor
    add sp, 2

    popa
    mov sp, bp
    pop bp
    ret

movecursor:
    push bp
    mov bp, sp
    pusha

    mov dx, [bp+4]      
    mov ah, 02h         
    mov bh, 0           
    int 10h

    popa
    mov sp, bp
    pop bp
    ret

putchar:
    mov ah, 0x0e
    mov bh, 0
    int 0x10
    ret

endl:
    mov al, 0x0a
    call putchar
    mov al, 0x0d
    call putchar
    ret

getchar:
    mov ah, 0x00
    int 16h
    ret

print:
    push bp
    mov bp, sp
    pusha

    mov si, [bp+4]
print_loop:
    lodsb 
    or al, 0
    je .end_print          
    call putchar           
    jmp print_loop       
.end_print:
    popa
    mov sp, bp
    pop bp
    ret

input:
    push bp
    mov bp, sp
    pusha

    mov cl, [bp+4]
    mov di, [bp+6]
input_loop:
    or cl, 0
    jz .end_input
    call getchar
    cmp al, 0x0d
    je .end_input
    mov byte[di], al
    call putchar
    inc di
    dec cl
    jmp input_loop
.end_input:
    popa
    mov sp, bp
    pop bp
    ret

strcmp:
    push bp
    mov bp, sp
    pusha

    mov cl, [bp+4]
    mov si, [bp+6]
    mov di, [bp+8]
cmp_loop:
    or cl, 0 
    jz .end
    mov bl, byte[di]
    lodsb
    or al, bl
    jz .end_equal
    cmp al, bl
    jne .end
    inc di
    dec cl
    jmp cmp_loop
.end_equal:
    mov al, 1
    mov byte[flag], al
.end:
    popa
    mov sp, bp
    pop bp
    ret

tip_top:
    push bp
    mov bp, sp
    pusha

    push 0x0c10
    push 0x70        
    call clear
    add sp, 4

    push 0x0423
    call movecursor
    add sp, 2

    push tip
    call print
    add sp, 2

    mov al, [bp+4]
    call putchar

    popa
    mov sp, bp
    pop bp
    ret


set_option:
    push bp
    mov bp, sp
    pusha

    loop:
        call getchar
        push ax
        cmp al, '1'
        je ans
        pop ax
        push ax
        cmp al, '2'
        je end_loop
        pop ax
        jmp loop
    end_loop:
        pop ax
        jmp set_done
    ans:
        pop ax
    
        push 0x0a0d
        push 0x70        
        call clear
        add sp, 4

        push msg
        call print
        add sp, 2

        push str1
        push 5
        call input
        add sp, 4

        push str1
        push str2
        push 5
        call strcmp
        add sp, 6

        mov al, [flag]
        cmp al, 0
        je wrong_ans

        push 0x0a1a
        push 0x27        
        call clear
        add sp, 4

        push correct
        call print
        add sp, 2
        jmp done

        wrong_ans:
            push 0x0a1c
            push 0x40        
            call clear
            add sp, 4

            push wrong
            call print
            add sp, 2
            jmp done

set_done:
    popa
    mov sp, bp
    pop bp
    ret


defaul_screen:
    push bp
    mov bp, sp
    pusha

    push word[bp+4]
    call tip_top
    add sp, 2

    push 0x0a0d
    call movecursor
    add sp, 2

    push word[bp+6]
    call print
    add sp, 2

    push 0x1013
    call movecursor
    add sp, 2
    
    
    push word[bp+8]
    call print
    add sp, 2

    popa
    mov sp, bp
    pop bp
    ret
    
start:
    push 0x0c10
    push 0x70        ; 0xbl, b = cor do background, l = cor da letra
    call clear
    add sp, 4

    push options1
    push tip1
    push '1'
    call defaul_screen
    add sp, 6

    call set_option

    push options1
    push tip2
    push '2'
    call defaul_screen
    add sp, 6

    call set_option

    push options2
    push tip3
    push '3'
    call defaul_screen
    add sp, 6

    call set_option
done:
    jmp $
