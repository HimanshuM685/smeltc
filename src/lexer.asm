%include "macros.inc"

section .data
  digits_str    db '0123456789', 0
  illegal_msg   db 'Illegal Character', 0

section .text 
  global lexer_make_tokens, lexer_make_number, print_tokens, print_error
  global token_create, error_create, is_digit, is_whitespace
  global lexer_advance

lexer_make_tokens:
  push ebp 
  mov ebp, esp 
  push esi
  push edi 
  push ebx

  mov esi, [ebp + 8]
  mov edi, [ebp + 12]
  mov ebx, [ebp + 16]

  xor ecx, ecx

.token_loop:
  cmp dword [esi + 28], 0
  je .done 

  mov eax, [esi + 28]

  push edx 
  IS_WHITESPACE eax, edx
  pop edx
  cmp edx, 1
  je .skip_whitespace

  push edx
  IS_DIGIT eax, edx
  pop edx
  cmp edx, 1
  je .make_number

  cmp eax, CHAR_PLUS
  je .make_plus
  cmp eax, CHAR_MINUS
  je .make_minus
  cmp eax, CHAR_MUL
  je .make_mul
  cmp eax, CHAR_DIV
  je .make_div 
  cmp eax, CHAR_LPAREN 
  je .make_lparen 
  cmp eax, CHAR_RPAREN 
  je .make_rparen

  jmp .illegal_char 

.skip_whitespace:
  push esi
  call lexer_advance
  add esp, 4
  jmp .token_loop

.make_number:
  push ecx
  push esi
  push edi
  call lexer_make_number
  add esp, 8
  pop ecx

  add edi, TOKEN_SIZE
  inc ecx
  jmp .token_loop

.make_plus:
  push TT_PLUS
  push 0
  push edi
  call token_create
  add esp, 12

  push esi
  call lexer_advance
  add esp, 4

  add edi, TOKEN_SIZE
  inc ecx
  jmp .token_loop

.make_minus:
  push TT_MINUS
  push 0
  push edi
  call token_create
  add esp, 12

  push esi
  call lexer_advance
  add esp, 4

  add edi, TOKEN_SIZE
  inc ecx
  jmp .token_loop

.make_mul:
    push TT_MUL
    push 0
    push edi
    call token_create
    add esp, 12
    
    push esi
    call lexer_advance
    add esp, 4
    
    add edi, TOKEN_SIZE
    inc ecx
    jmp .token_loop

.make_div:
    push TT_DIV
    push 0
    push edi
    call token_create
    add esp, 12
    
    push esi
    call lexer_advance
    add esp, 4
    
    add edi, TOKEN_SIZE
    inc ecx
    jmp .token_loop

.make_lparen:
    push TT_LPAREN
    push 0
    push edi
    call token_create
    add esp, 12
    
    push esi
    call lexer_advance
    add esp, 4
    
    add edi, TOKEN_SIZE
    inc ecx
    jmp .token_loop

.make_rparen:
    push TT_RPAREN
    push 0
    push edi
    call token_create
    add esp, 12
    
    push esi
    call lexer_advance
    add esp, 4
    
    add edi, TOKEN_SIZE
    inc ecx
    jmp .token_loop

.illegal_char:
    ; Create error
    mov eax, ERR_ILLEGAL_CHAR
    mov [ebx], ecx
    jmp .error_exit

.done:
    mov [ebx], ecx
    mov eax, ERR_NONE
    
.error_exit:
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret

lexer_make_number:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    
    mov esi, [ebp + 8]      ; lexer struct
    mov edi, [ebp + 12]     ; token position
    
    ; Use temp buffer for number string
    extern temp_buffer
    mov ebx, temp_buffer
    xor ecx, ecx
    xor edx, edx
    
.number_loop:
    mov eax, [esi + 28]
    cmp eax, 0
    je .end_number
    
    push edx
    IS_DIGIT eax, edx
    cmp edx, 1
    pop edx
    je .add_digit
    
    cmp eax, CHAR_DOT
    je .add_dot
    
    jmp .end_number

.add_digit:
    mov [ebx + ecx], al
    inc ecx
    
    push esi
    call lexer_advance
    add esp, 4
    jmp .number_loop

.add_dot:
    cmp edx, 1
    je .end_number
    
    mov [ebx + ecx], al
    inc ecx
    inc edx 
    
    push esi
    call lexer_advance
    add esp, 4
    jmp .number_loop

.end_number:
    mov byte [ebx + ecx], 0 ; null terminate
    
    cmp edx, 0
    je .make_int
    
    push TT_FLOAT
    push ebx
    push edi
    call token_create
    add esp, 12
    jmp .done

.make_int:
    push ebx
    call atoi
    add esp, 4
    
    push TT_INT
    push eax
    push edi
    call token_create
    add esp, 12

.done:
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret


atoi:
    push ebp
    mov ebp, esp
    push esi
    push ebx
    
    mov esi, [ebp + 8]
    xor eax, eax
    xor ebx, ebx
    
.atoi_loop:
    mov bl, [esi]
    cmp bl, 0
    je .atoi_done
    
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .atoi_loop
    
.atoi_done:
    pop ebx
    pop esi
    pop ebp
    ret

token_create:
    push ebp
    mov ebp, esp
    push edi
    
    mov edi, [ebp + 8]
    mov eax, [ebp + 12]
    mov [edi], eax
    mov eax, [ebp + 16]
    mov [edi + 4], eax
    
    pop edi
    pop ebp
    ret

error_create:
    push ebp
    mov ebp, esp
 
    pop ebp
    ret

is_digit:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    IS_DIGIT eax, eax
    pop ebp
    ret

is_whitespace:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    IS_WHITESPACE eax, eax
    pop ebp
    ret

print_tokens:
    push ebp
    mov ebp, esp
    push esi
    push ebx
    
    mov esi, [ebp + 8]
    mov ebx, [ebp + 12]
    
    xor ecx, ecx
    
.print_loop:
    cmp ecx, ebx
    jge .print_done
    
    mov eax, [esi + ecx * TOKEN_SIZE]
    
    add eax, '0'
    push eax
    lea eax, [esp]
    SYS_WRITE 1, eax, 1
    pop eax
    
    mov al, ' '
    push eax
    lea eax, [esp]
    SYS_WRITE 1, eax, 1
    pop eax
    
    inc ecx
    jmp .print_loop
    
.print_done:
    mov al, 10
    push eax
    lea eax, [esp]
    SYS_WRITE 1, eax, 1
    pop eax
    
    pop ebx
    pop esi
    pop ebp
    ret

print_error:
    push ebp
    mov ebp, esp
    
    mov eax, illegal_msg
    call print_string
    
    pop ebp
    ret

print_string:
    push ebp
    mov ebp, esp
    push esi
    push eax
    
    mov esi, eax
    call strlen
    SYS_WRITE 1, esi, eax
    
    pop eax
    pop esi
    pop ebp
    ret

lexer_advance:
    ret

lexer_init:
    ret

extern strlen