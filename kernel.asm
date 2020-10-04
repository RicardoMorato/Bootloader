org 0x7e00
jmp 0x0000:start

data:
    welcome db 'Bem vindo ao jogo do Silvio Santos', 0
    msg_return db 'Pressione qualquer tecla para voltar', 0
    initial_options db '(1) jogar     (2) como jogar     (3) creditos', 0

    msg_how_to_play_1 db 'Esse jogo foi criado para testar o seu brio, pessoa que esta lendo isso. Voce vai receber dicas (no maximo 3) para acertar uma palavra, caso voce consiga, parabens, voce tem brio, caso contrario...', 0
    msg_how_to_play_2 db 'Para jogar, va ao menu principal (so pressionar qualquer tecla) e pressione 1 no seu teclado. Ao fazer isso voce sera redirecionado para a primeira dica da palavra. La, voce pode optar por responder direto (so pressionar 1) ou por receber outra dica (pressionando 2). Como ja foi dito antes, voce tem direito a no maximo 3 dicas. Vamo ver se voce eh leao!!', 0
    msg_how_to_play_3 db 'A sorte esta lancada. Que Kant, ACM e todos os outros pensadores estejam com voce. Boa sorte, nobre usuario!', 0

    msg_credits_1 db 'Este jogo foi desenvolvido para a cadeira Infraestrutura de software por:', 0
    msg_credits_leo db '    - Leonardo Gabriel Moreira de Oliveira - LGMO,', 0
    msg_credits_ric db '    - Ricardo Morato Rocha - RMR,', 0
    msg_credits_ken db '    - Kennedy Edmilson Cunha Melo - KECM,', 0
    msg_credits_vitu db '    - Vituriano Oliveira Xisto - VOX', 0
    msg_credits_2 db 'Agradecimentos especiais aos monitores, a todos os tutoriais da internet e ao pensador Clovis de Barros Filho, que nos deu o brio necessario para terminar esse projeto', 0

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
    push bp            ; coloca a posição atual de bp na pilha
    mov bp, sp         ; faz bp apontar para a posição de bp apontar para o fim da pilha
    pusha              ; salva o valor dos registradores na pilha


                       ; [bp] = valor inicial de bh
                       ; [bp+2] = endereço de retorno
                       ; [bp+4] = último parâmetro adicionado na pilha

    mov ah, 07h        ; código para função rolagem de tela
    mov bh, [bp+4]     ; coloca em bh o primeiro parâmetro desse procedimento
    mov al, 00h        ; indica que é pra limpar a tela
    mov cx, 00h        ; ponto da extremidade superior esquerda do retângulo a ser  limpo (0, 0)
    mov dh, 18h        ; y do ponto da extremidade superior direita do retângulo a ser limpo
    mov dl, 4fh        ; x do ponto da extremidade superior direita do retângulo a ser limpo
    int 10h            ; chamada para interrupção de BIOS 10h


    push word[bp+6]    ; coloca o segundo parâmetro desse procedimento(clear) como parâmetro de movecursor
    call movecursor
    add sp, 2

    popa               ; restaura os valores dos registradores, os que foram adicionados a pilha em pusha
    mov sp, bp         ; restaura o valor de sp
    pop bp             ; restaura o valor de bp antes do call defaul_screen
    ret

movecursor:
    push bp
    mov bp, sp
    pusha

    mov dx, [bp+4]     ; coloca em dx a word que diz a linha e a coluna para onde o cursor deve ser movido
    mov ah, 02h        ; código para a função que move o cursor
    mov bh, 0
    int 10h

    popa
    mov sp, bp
    pop bp
    ret

putchar:
    mov ah, 0eh        ; código para função que imprime o valor de al na tela
    mov bh, 0          ; página onde será impresso o caracter
    int 10h
    ret


endl:
    mov al, 0ah        ; coloca em al o caracter de quebra de linha
    call putchar
    mov al, 0dh        ; coloca em al o caracter de carriage return
    call putchar
    ret

getchar:
    mov ah, 0x00       ; código para a função que coloca em al o valor da tecla que foi pressionada
    int 16h            ; chamada para interrupção da bios 16h
    ret

print:
    push bp
    mov bp, sp
    pusha

    mov si, [bp+4]     ; passa pra si o valor do primeiro parâmetro desse procedimento, primeiro posição de memória da string a ser lida
    .print_loop:
        ; mov al, [si]
        ; inc si
        lodsb          ; coloca em al o valor do byte na posição armazenada em si, depois si vai apontar par ao próximo byte na memória
        cmp al, 0
        je .end_print
        call putchar
        jmp .print_loop
    .end_print:
        popa
        mov sp, bp
        pop bp
    ret

input:
    push bp
    mov bp, sp
    pusha

    mov cl, [bp+4]     ; passa pra cl o primeiro parâmetro desse procedimento, tamanho da string a ser lida
    mov di, [bp+6]     ; passa para di o segundo parâmetro desse procedimento, posição de memória pra armazenar a string
    .input_loop:
        cmp cl, 0
        je .end_input
        call getchar
        cmp al, 0dh    ; compara al com o caracter de carriage return, se tiver sido pressionado enter vai dar igual
        je .end_input
        cmp al, 08h
        je .bck
        mov [di], al   ; coloca o valor de al na posição de memória armazenada em di
        call putchar
        inc di
        dec cl
        jmp .input_loop
    .bck:
        mov bl, [bp+4] ; coloca em bl o tamanho da string
        cmp cl, bl     ; vê se o contador tem o tamanho da string se tiver volta pra o loop
        je .input_loop
        call putchar   ; imprime o caracter de backspace
        mov al, ' '
        call putchar   ; cobre a letra atual com ' '
        mov al, 08h    ; backspace
        call putchar   ; imprime backspace de novo
        inc cl
        dec di         ; limpa o caracter apagado da string
        mov byte[di], 0
        jmp .input_loop
    .end_input:
        popa
        mov sp, bp
        pop bp
    ret

strcmp:
    push bp
    mov bp, sp
    pusha

    mov cl, [bp+4]     ; tamanho
    mov si, [bp+6]     ; resposta
    mov di, [bp+8]     ; input
    .cmp_loop:
        cmp cl, 0      ; se cl for 0 o resultado é 0, do contrário cl mantém seu valor
        je .end
        mov bl, [di]   ; coloca o byte na posição armazenada de di em bl
        lodsb          ; coloca o valor na posição armazenada em si em al
        cmp al, bl
        je .end_equal
        cmp al, bl
        jne .end_different
        inc di
        dec cl
        jmp .cmp_loop
    .end_equal:
        mov al, 1
        mov [flag], al
        jmp .end
    .end_different:
        mov al, 0
        mov [flag], al
    .end:
        popa
        mov sp, bp
        pop bp
    ret

tip_top:
    push bp
    mov bp, sp
    pusha

    push 0x0423        ; passa os parâmetros para usar no movecursor do clear
    push 70h           ; passa os parâmetros para mudar a cor da letra e tela
    call clear
    add sp, 4          ; remove da pilha os parâmetros

    push tip           ; parâmetro para print
    call print
    add sp, 2

    mov al, [bp+4]     ; passa o primeiro parâmetro desse procedimento(tip_top) em al
    call putchar

    popa
    mov sp, bp
    pop bp
    ret

set_option:
    push bp
    mov bp, sp
    pusha

    mov al, [bp+4]     ; coloca em al o primeiro parâmetro desse procedimento
    cmp al, 1
    je .read_loop1
    .read_loop:
        call getchar
        cmp al, '1'
        je .ans
        cmp al, '2'
        je .set_done
        jmp .read_loop
    .read_loop1:
        call getchar
        cmp al, '1'
        je .ans
        jmp .read_loop1
    .ans:
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

        mov al, [flag] ; o byte na posição armazenada em flag tem o resultado da comparação, passamos ele para al pra fazer o cmp
        cmp al, 0      ; se for 0 str1 e str2 são diferentes
        je .wrong_ans

        push 0x0a1a
        push 0x27
        call clear
        add sp, 4

        push correct
        call print
        add sp, 2

        popa
        mov sp, bp
        pop bp
        add sp, 4
        jmp game.end_game

        .wrong_ans:
            push 0x0a1c
            push 0x40
            call clear
            add sp, 4

            push wrong
            call print
            add sp, 2

            popa
            mov sp, bp
            pop bp
            add sp, 4
            jmp game.end_game
    .set_done:
        popa
        mov sp, bp
        pop bp
    ret


defaul_screen:
    push bp            ; coloca a posição atual de bp na pilha
    mov bp, sp         ; faz bp apontar para a posição de bp apontar para o fim da pilha
    pusha              ; salva o valor dos registradores na pilha

    push word[bp+4]    ; coloca o 1º parâmetro dessa função(defaul_screen) na pilha para ser parâmetro de tip_top
    call tip_top
    add sp, 2



    push 0x0a0d        ; coloca na pilha os parâmetros para movecursor
    call movecursor
    add sp, 2


    ; imprime na tela a string cuja a posição inicial é word[bp+6]

    push word[bp+6]    ; coloca na pilha o 2º par
    call print
    add sp, 2

    push 0x1013
    call movecursor
    add sp, 2


    push word[bp+8]
    call print
    add sp, 2

    popa               ; restaura os valores dos registradores, os que foram adicionados a pilha em pusha
    mov sp, bp
    pop bp             ; restaura o valor de bp antes do call defaul_screen
    ret

how_to_play:
    push bp
    mov bp, sp
    pusha

    push 0x1617
    push 0x8c
    call clear
    add sp, 4

    push msg_return
    call print
    add sp, 2

    push 0x0104
    call movecursor
    add sp, 2

    push msg_how_to_play_1
    call print
    add sp, 2

    push 0x0604
    call movecursor
    add sp, 2

    push msg_how_to_play_2
    call print
    add sp, 2

    push 0x0d04
    call movecursor
    add sp, 2

    push msg_how_to_play_3
    call print
    add sp, 2

    call getchar
    call game

    popa
    mov sp, bp
    pop bp
    ret

credits:
    push bp
    mov bp, sp
    pusha

    push 0x1617
    push 0x6f
    call clear
    add sp, 4

    push msg_return
    call print
    add sp, 2

    push 0x0104
    call movecursor
    add sp, 2

    push msg_credits_1
    call print
    add sp, 2

    call endl
    call endl
    push msg_credits_leo
    call print
    add sp, 2

    call endl
    push msg_credits_ric
    call print
    add sp, 2

    call endl
    push msg_credits_ken
    call print
    add sp, 2

    call endl
    push msg_credits_vitu
    call print
    add sp, 2

    push 0x0804
    call movecursor
    add sp, 2

    push msg_credits_2
    call print
    add sp, 2

    call getchar
    call game

    popa
    mov sp, bp
    pop bp
    ret

game:
    .loop:
        call menu
        push 0x0c10
        push 0x70
        call clear
        add sp, 4

        push options1
        push tip1
        push '1'
        call defaul_screen
        add sp, 6

        push 0
        call set_option
        add sp, 2

        push options1
        push tip2
        push '2'
        call defaul_screen
        add sp, 6

        push 0
        call set_option
        add sp, 2

        push options2
        push tip3
        push '3'
        call defaul_screen
        add sp, 6

        push 1
        call set_option
        add sp, 2
        .end_game:
        	call getchar
        jmp .loop
    ret

menu:
    push bp
    mov bp, sp
    pusha

    .start_menu:
        push 0x0117
        push 0x3c
        call clear
        add sp, 4

        push welcome
        call print
        add sp, 2

        push 0x1010
        call movecursor
        add sp, 2

        push initial_options
        call print
        add sp,2

    .get_options:
        call getchar
        cmp al, '1'
        je .end_menu
        cmp al, '2'
        je .call_how_to_play
        cmp al, '3'
        je .call_credits
        jmp .get_options

    .call_how_to_play:
        call how_to_play

    .call_credits:
        call credits

    .end_menu:
        popa
        mov sp, bp
        pop bp
    ret

start:
    call game

done:
    jmp $
