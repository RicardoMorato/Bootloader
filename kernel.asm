org 0x7e00
jmp 0x0000:start

data:
    mensagem db 'Informe o valor de X entre 1 e 1000',0
    string times 20 db 0
    X times 10 db 0
    valor times 10 db 0

putchar:               ; Printa um caractere na tela, pega o valor salvo em al
  mov ah, 0x0e
  int 10h
  ret

getchar:               ; Pega o caractere lido no teclado e salva em al
  mov ah, 0x00
  int 16h
  ret

delchar:               ; Deleta um caractere lido no teclado
  mov al, 0x08         ; backspace
  call putchar
  mov al, ' '
  call putchar
  mov al, 0x08         ; backspace
  call putchar
  ret

endl:                  ; Pula uma linha, printando na tela o caractere que representa o /n
  mov al, 0x0a         ; line feed
  call putchar
  mov al, 0x0d         ; carriage return
  call putchar
  ret

reverse:               ; mov si, string, pega a string apontada por si e a reverte
  mov di, si
  xor cx, cx           ; zerar contador
  .loop1:              ; botar string na stack
    lodsb
    cmp al, 0
    je .endloop1
    inc cl
    push ax
    jmp .loop1
  .endloop1:
  .loop2:              ; remover string da stack
    pop ax
    stosb
    loop .loop2
  ret

gets:                  ; mov di, string, salva na string apontada por di, cada caractere lido na linha
  xor cx, cx           ; zerar contador
  .loop1:
    call getchar
    cmp al, 0x08       ; backspace
    je .backspace
    cmp al, 0x0d       ; carriage return
    je .done
    cmp cl, 10         ; string limit checker
    je .loop1

    stosb
    inc cl
    call putchar

    jmp .loop1
    .backspace:
      cmp cl, 0        ; is empty?
      je .loop1
      dec di
      dec cl
      mov byte[di], 0
      call delchar
    jmp .loop1
  .done:
  mov al, 0
  stosb
  call endl
  ret

strcmp:                ; mov si, string1, mov di, string2, compara as strings apontadas por si e di
  .loop1:
    lodsb
    cmp al, byte[di]
    jne .notequal
    cmp al, 0
    je .equal
    inc di
    jmp .loop1
  .notequal:
    clc
    ret
  .equal:
    stc
    ret

tostring:              ; mov ax, int / mov di, string, transforma o valor em ax em uma string e salva no endereço apontado por di
    push di
    .loop1:
        cmp ax, 0
        je .endloop1
        xor dx, dx
        mov bx, 10
        div bx         ; ax = 9999 -> ax = 999, dx = 9
        xchg ax, dx    ; swap ax, dx
        add ax, 48     ; 9 + '0' = '9'
        stosb
        xchg ax, dx
        jmp .loop1
    .endloop1:
    pop si
    cmp si, di
    jne .done
    mov al, 48
    stosb
    .done:
    mov al, 0
    stosb
    call reverse
    ret

  prints:              ; mov si, string
    .loop:
        lodsb          ; bota character apontado por si em al
        cmp al, 0      ; 0 é o valor atribuido ao final de uma string
        je .endloop    ; Se for o final da string, acaba o loop
        call putchar   ; printa o caractere
        jmp .loop      ; volta para o inicio do loop
    .endloop:
    ret

clear:                 ; mov bl, color
                       ; seta o cursor para o canto superior esquerdo da tela
  mov dx, 0
  mov bh, 0
  mov ah, 0x2
  int 0x10

  ; print 2000 blank chars to clean
  mov cx, 2000
  mov bh, 0
  mov al, 0x20         ; blank char
  mov ah, 0x9
  int 0x10

  ; reseta o cursor para o canto superior esquerdo da tela
  mov dx, 0
  mov bh, 0
  mov ah, 0x2
  int 0x10
  ret

start:

    xor ax, ax         ; limpando ax
    mov ds, ax         ; limpando ds
    mov es, ax         ; limpando es

                       ; limpando a tela, em bl fica o valor da cor que vai ser utilizada na tela, 15 é o valor branco, outras cores disponíveis no tutorial

    mov bl, 15
    call clear

    ; Imprimindo na tela a mensagem declarada em data
    mov si, mensagem   ; si aponta para o começo do endereço onde está mensagem
    call prints        ; Como só é impresso um caractere por vez, pegamos uma string com N caracteres e printamos um por um em ordem até chegar ao caractere de valor 0 que é o fim da string, assim prints pega a string para qual o ponteiro si aponta e a imprime na tela até o seu final
    call endl          ; Pula uma linha, assim o próximo caractere imprimido estará na linha de baixo

                       ; lendo o valor de X
    mov di, X          ; di aponta para o começo do endereço onde está X
    call gets          ; Como só é lido um caractere por vez, caso X seja um número com 2 ou mais casas decimais, a forma mais eficiente de salvar esse número é em forma de string, assim a gets salva no endereço apontado por di cada caractere lido do teclado até o enter
    call endl

    ; Printando os valores de 1 até X
    xor ax,ax
    xor cx,cx
    mov ax,1
    push ax            ; Salvando o valor inicial de ax na pilha
    .printando:        ; Forma de declarar uma label dentro de outra, colocar um "."antes da declaração

                       ; Trasformando o valor atual em uma string para exibir
        mov di, valor
        call tostring  ; Pega o valor em ax e salva em forma de string no endereço apontado por di, como em asm só printamos 1 caractere por vez, para printar um número com 2 ou mais casas decimais é preciso converter ele em uma string e printar casa por casa em ordem e assim representar o número desejado

                       ; Exibindo valor atual
        mov si, valor
        call prints
        call endl

        ; Verificando se o valor atual chegou em X, caso não tenha, continua o loop
        mov si, X
        mov di, valor
        call strcmp    ; Compara as strings apontadas por si e di, retornando se são iguais ou não, assim sabemos se o valor atual é igual ao valor de X

        je .end        ; Se as strings são iguais, pula para label .end

                       ; Adicionando 1 ao valor atual para continuar a exibição
        xor ax,ax
        pop ax         ; Tira da pilha o valor de ax
        add ax,1       ; ax = ax+1
        push ax        ; Salva na pilha o valor novo de ax
        jmp .printando ; Volta para .printando

    .end:
    jmp done

done:
    jmp $
