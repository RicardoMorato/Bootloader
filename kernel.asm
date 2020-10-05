
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
    msg_credits_2 db 'Agradecimentos especiais aos monitores, a todos os tutoriais da internet e ao pensador Clovis de Barros Filho, que nos deu o brio necessario para terminar esse projeto.', 0

    ans1_tip1 db 'Login', 0
    ans1_tip2 db 'Eu tenho um suco de manga', 0
    ans1_tip3 db 'kkkkkkkkk eh brincadeira', 0

    ans2_tip1 db 'Eu dizer, malandro voce eh tosquinho, voce nao entende', 0
    ans2_tip2 db '  ISSO NA QUINTA SERIE PRIMARIA, JA DARIA PRA ENTENDER', 0
    ans2_tip3 db '    SE NAO O NEGO CAGA NA SUA CABECA, E VOCE NAO REAGE', 0

    ans3_tip1 db 'Tipo de arma', 0
    ans3_tip2 db 'Atira pedras longe', 0
    ans3_tip3 db 'Usada na grecia antiga', 0

    ans4_tip1 db 'Muito comum em governos autoritarios', 0
    ans4_tip2 db 'Utilizada na Inquisicao', 0
    ans4_tip3 db 'Codar em assembly eh uma...', 0

    tip db 'Dica ',0
    options1 db '(1) Responder      (2) Proxima dica' , 0
    options2 db '           (1) Responder' , 0
    msg db 'Digite a resposta: ', 0
    correct db 'Parabens! Voce tem brio ;)', 0
    wrong db 'Voce nao entende :/', 0
    user_ans times 20 db 0

    ans1 db 'acm', 0
    ans2 db 'brio', 0
    ans3 db 'catapulta', 0
    ans4 db 'tortura', 0

    flag db 0

    msg_pontuacao db 'Sua pontuacao foi: ', 0
    score0 db '0', 0
    score1 db '50', 0
    score2 db '100', 0
    score3 db '150', 0
    score4 db '200', 0

    cont db 0

%macro begin 0
    push bp              ; coloca a posição atual de bp na pilha
    mov bp, sp           ; faz bp apontar para a posição de bp apontar para o fim da pilha
    pusha                ; salva o valor dos registradores na pilha
%endmacro

%macro end 0
    popa
    mov sp, bp
    pop bp
%endmacro

%macro turn 2
    push options1        ; string das opções
    push ans%2_tip1      ; dica 1 do turno atual
    push '1'             ; número da dica
    call default_screen
    add sp, 6

    push %1              ; tamanho da string de resposta
    push ans%2           ; string da resposta certa
    push %2              ; número do turno atual
    push 0               ; 0 indica que vai ter duas opçoes
    call set_option
    add sp, 8

    push options1
    push ans%2_tip2      ; dica 2 do turno atual
    push '2'
    call default_screen
    add sp, 6


    push %1
    push ans%2
    push %2
    push 0
    call set_option
    add sp, 8

    push options2
    push ans%2_tip3      ; dica 3 do turno atual
    push '3'
    call default_screen
    add sp, 6

    push %1
    push ans%2
    push %2
    push 1               ; indica que o usuário só tem 1 opção
    call set_option

    .end_turn%2:         ; o programa vem pra cá depois que o usuário responde
    end                  ; como ele não veio pelo ret, é preciso restaurar os registradores
    add sp, 10           ; tirar os parâmetros da pilha e o endereço de retorno
%endmacro

%macro next 0
    ; remove da pilha os parâmetros da set_option e o
    ; e o endereço de retorno
    mov al, [bp+6]       ; [bp+6] tem o número do turno atual
    cmp al, 1
    je game.end_turn1    ; final do turno 1
    cmp al, 2
    je game.end_turn2    ; final do turno 2
    cmp al, 3
    je game.end_turn3    ; final do turno 3
    jmp game.end_turn4
%endmacro



clear:
    begin

    mov ah, 07h          ; código para função rolagem de tela
    mov bh, [bp+4]       ; coloca em bh o parâmetro 1 desse procedimento(cor)
    mov al, 00h          ; indica que é pra limpar a tela
    mov cx, 00h          ; ponto da extremidade superior esquerda do retângulo a ser  limpo (0, 0)
    mov dh, 18h          ; y do ponto da extremidade superior direita do retângulo a ser limpo
    mov dl, 4fh          ; x do ponto da extremidade superior direita do retângulo a ser limpo
    int 10h              ; chamada para interrupção de BIOS 10h


    push word[bp+6]      ; coloca o parâmetro 2 desse procedimento como parâmetro de movecursor
    call movecursor
    add sp, 2

    end
    ret
movecursor:
    begin

    mov dx, [bp+4]       ; coloca em dx a word que diz a linha e a coluna para onde o cursor deve ser movido
    mov ah, 02h          ; código para a função que move o cursor
    mov bh, 0
    int 10h

    end
    ret

putchar:
    mov ah, 0eh          ; código para função que imprime o valor de al na tela
    mov bh, 0            ; página onde será impresso o caracter
    int 10h
    ret

endl:
    mov al, 0ah          ; coloca em al o caracter de quebra de linha
    call putchar
    mov al, 0dh          ; coloca em al o caracter de carriage return
    call putchar
    ret

getchar:
    mov ah, 0x00         ; código para a função que coloca em al o valor da tecla que foi pressionada
    int 16h              ; chamada para interrupção da bios 16h
    ret

print:
    begin

    mov si, [bp+4]       ; passa pra si o valor do parâmetro 1 desse procedimento, primeiro posição de memória da string a ser lida
    .print_loop:
        ; mov al, [si]
        ; inc si
        lodsb            ; coloca em al o valor do byte na posição armazenada em si, depois si vai apontar par ao próximo byte na memória
        cmp al, 0
        je .end_print
        call putchar
        jmp .print_loop
    .end_print:
        end
    ret

input:
    begin

    mov cl, [bp+4]       ; passa pra cl o primeiro parâmetro desse procedimento, tamanho da string a ser lida
    mov di, [bp+6]       ; passa para di o  parâmetro 2 desse procedimento, posição de memória pra armazenar a string
    .input_loop:
        cmp cl, 0
        je .end_input
        call getchar
        cmp al, 0dh      ; compara al com o caracter de carriage return, se tiver sido pressionado enter vai dar igual
        je .end_input
        cmp al, 08h      ; compara al com o caracter backspace
        je .bck
        mov [di], al     ; coloca o valor de al na posição de memória armazenada em di
        call putchar
        inc di           ; di vai apontar para a próxima posição na memória
        dec cl
        jmp .input_loop
    .bck:
        mov bl, [bp+4]   ; coloca em bl o tamanho da string
        cmp cl, bl       ; vê se o contador tem o tamanho da string se tiver volta pra o loop
        je .input_loop
        call putchar     ; imprime o caracter de backspace
        mov al, ' '
        call putchar     ; cobre a letra atual com ' '
        mov al, 08h      ; backspace
        call putchar     ; imprime backspace de novo
        inc cl
        dec di           ; limpa o caracter apagado da string
        mov byte[di], 0
        jmp .input_loop
    .end_input:
        end
    ret

strcmp:
    begin

    mov cl, [bp+4]       ; tamanho da menos das strings que serão comparadas
    mov si, [bp+6]       ; string resposta
    mov di, [bp+8]       ; string resposta do usuário
    .cmp_loop:
        cmp cl, 0
        je .end_equal
        mov bl, [di]     ; coloca o byte na posição armazenada de di em bl
        lodsb            ; coloca o valor na posição armazenada em si em al
        cmp al, bl
        jne .end_different
        inc di
        dec cl
        jmp .cmp_loop
    .end_equal:
        ; precisa ver se depois da string certa tem um 0
        ; ou uma letra exemplo 'brio',0(correto) ou 'brioo', 0(errado)
        cmp byte[di], 0
        jne .end_different
        mov al, 1
        mov [flag], al
        jmp .erase
    .end_different:
        mov al, 0
        mov [flag], al
        ; limpa a string da resposta do usuário
    .erase:
        mov cl, 15
        mov di, [bp+8]
        .erase_loop:
            cmp cl, 0
            je .end
            mov byte[di], 0
            inc di
            dec cl
            jmp .erase_loop
    .end:
        end
    ret

tip_top:
    begin

    push 0x0423          ; passa os parâmetros para usar no movecursor do clear
    push 70h             ; passa os parâmetros para mudar a cor da letra e tela
    call clear
    add sp, 4            ; remove da pilha os parâmetros

    push tip             ; parâmetro para print, é a strin "dica"
    call print
    add sp, 2

    mov al, [bp+4]       ; passa o parâmetro 1 desse procedimento(número da dica atual) para al
    call putchar

    end
    ret

set_option:
    begin

    mov al, [bp+4]       ; coloca em al o parâmetro 1 desse procedimento, o char que indica o número de opções
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

        push user_ans    ; string para armazenar a resposta do usuário
        push 15
        call input
        add sp, 4

        push user_ans
        push word[bp+8]  ; string da resposta correta
        push word[bp+10] ; tamanho da string da certa
        call strcmp
        add sp, 6

        mov al, [flag]   ; o byte na posição armazenada em flag tem o resultado da comparação, passamos ele para al pra fazer o cmp
        cmp al, 0        ; se for 0 string cerrta e a do usuário são diferentes
        je .wrong_ans

        mov al, [cont]
        inc al
        mov [cont], al

        push 0x0a1a
        push 0x27
        call clear
        add sp, 4

        push correct
        call print
        add sp, 2
        call getchar
        next             ; vai pro fim do turno atual
        .wrong_ans:
            push 0x0a1c
            push 0x40
            call clear
            add sp, 4

            push wrong
            call print
            add sp, 2
            call getchar
            next         ; vai pro fim do turno atual
    .set_done:
        end
    ret


default_screen:
    begin

    push word[bp+4]      ; coloca o 1º parâmetro dessa função(número da dica atual) na pilha para ser parâmetro de tip_top
    call tip_top
    add sp, 2



    push 0x0a0d          ; coloca na pilha os parâmetros para movecursor
    call movecursor
    add sp, 2


    ; imprime na tela a string do parametro 2, dica 2 do turno atual

    push word[bp+6]
    call print
    add sp, 2

    push 0x1013
    call movecursor
    add sp, 2


    push word[bp+8]      ; imprime na tela as opções que essa dica tem
    call print
    add sp, 2

    end
    ret

pontuacao:
    begin

    push 0x0919
    push 0x0f
    call clear           ; Limpa a tela
    add sp, 4

    push msg_pontuacao
    call print           ; Printa a mensagem "Sua pontuacao foi: "
    add sp, 2

    mov al, [cont]       ; Move o valor do contador para o registrador al

    cmp al, 0            ; Compara para ver se o valor no al é 0. Se sim, significa que a pessoa não acertou nenhuma palavra e, portanto, a label .score_0 é chamada, para mostrar a mensagem certa
    je .score_0

    cmp al, 1            ; Compara o valor em al para ver se é 1. Se sim, significa que a pessoa só acertou uma palavra
    je .score_1

    cmp al, 2            ; Compara o valor em al para ver se é 2. Se sim, significa que a pessoa só acertou duas palavras
    je .score_2

    cmp al, 3            ; Compara o valor em al para ver se é 3. Se sim, significa que a pessoa só acertou três palavras
    je .score_3

    cmp al, 4            ; Compara o valor em al para ver se é 4. Se sim, significa que a pessoa só acertou quatro (todas) palavras
    je .score_4

    .score_0:
        push score0
        call print
        add sp,2
        jmp .end_pontuacao

    .score_1:
        push score1
        call print
        add sp,2
        jmp .end_pontuacao

    .score_2:
        push score2
        call print
        add sp,2
        jmp .end_pontuacao

    .score_3:
        push score3
        call print
        add sp,2
        jmp .end_pontuacao

    .score_4:
        push score4
        call print
        add sp,2
        jmp .end_pontuacao

    .end_pontuacao:
        call getchar ; Invoca o procedimento getchar para travar o fluxo do jogo até que o usuário pressione uma tecla para sair da tela
        mov al, 0 ; Muda o valor registrado em al para zero
        mov [cont], al ; Reinicia o contador

        end
    ret

how_to_play:
    begin

    push 0x1617
    push 0x8c
    call clear           ; Limpa a tela
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

    end
    ret

credits:
    begin

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

    end
    ret

game:
    .loop:
        call menu
        push 0x0c10
        push 0x70
        call clear
        add sp, 4

        turn 3, 1        ; 3 tamanho da palavvra a ser adivinhada, 1 número do turno
        turn 4, 2
        turn 9, 3
        turn 7, 4

        call getchar
        call pontuacao
        jmp .loop
    ret

menu:
    begin

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
        end
    ret

start:
    call game

done:
    jmp $
