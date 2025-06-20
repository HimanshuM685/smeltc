%include "macros.inc"

section .data
  digits_str    db '0123456789', 0
  illegal_msg   db 'Illegal Character', 0

section .text 
  global lexer_make_tokens, lexer_make_number, print_tokens, print_error
  global token_create, error_create, is_digit, is_whitespace
  global lexer_advance
  global parser_parse
  global lexer_init

lexer_make_tokens:
  push ebp 
  mov ebp, esp 
  push esi
  push edi 
  push ebx

  mov esi, [ebp + 8]      ; lexer struct
  mov edi, [ebp + 12]     ; token buffer
  mov ebx, [ebp + 16]     ; num_tokens pointer

  xor ecx, ecx

.token_loop:
  mov eax, [esi + 28]     ; current_char
  cmp eax, 0
  je .done 

  ; Debug: check what character we're processing
  cmp eax, 255
  jg .illegal_char        ; Invalid character

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
  cmp eax, CHAR_NEWLINE
  je .skip_whitespace

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
    push ecx
    push edx
    
    mov esi, [ebp + 8]      ; token buffer
    mov ebx, [ebp + 12]     ; num_tokens
    
    ; Check if we have any tokens
    cmp ebx, 0
    je .print_done
    
    xor ecx, ecx
    
.print_loop:
    cmp ecx, ebx
    jge .print_done
    
    ; Calculate token offset: ecx * TOKEN_SIZE
    mov eax, ecx
    mov edx, TOKEN_SIZE
    mul edx
    
    ; Get token type
    mov edx, [esi + eax]    ; token type
    
    ; Print token type as character
    cmp edx, 10
    jl .single_digit
    
    ; For larger numbers, print the actual digit
    add edx, '0'
    jmp .print_char
    
.single_digit:
    add edx, '0'
    
.print_char:
    ; Print the character
    push edx
    mov eax, esp
    SYS_WRITE 1, eax, 1
    pop edx
    
    ; Print space separator
    push ' '
    mov eax, esp
    SYS_WRITE 1, eax, 1
    pop eax
    
    inc ecx
    jmp .print_loop
    
.print_done:
    ; Print newline
    push 10
    mov eax, esp
    SYS_WRITE 1, eax, 1
    pop eax
    
    pop edx
    pop ecx
    pop ebx
    pop esi
    pop ebp
    ret

print_error:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    
    ; Print "Illegal Character" message
    mov eax, illegal_msg
    call print_string
    
    ; Print newline
    push 10
    mov eax, esp
    SYS_WRITE 1, eax, 1
    pop eax
    
    pop edx
    pop ecx
    pop ebx
    pop eax
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

lexer_init:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov esi, [ebp + 8]      ; lexer struct
    mov edi, [ebp + 12]     ; input string
    
    mov [esi], edi          ; text pointer
    mov dword [esi + 4], 0  ; position
    mov dword [esi + 8], 0  ; line
    mov dword [esi + 12], 0 ; column
    
    ; Set current_char
    mov al, [edi]
    mov [esi + 28], eax
    
    pop edi
    pop esi
    pop ebp
    ret

lexer_advance:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov esi, [ebp + 8]      ; lexer struct
    
    ; Get text pointer and current position
    mov edi, [esi]          ; text pointer
    mov eax, [esi + 4]      ; position
    
    ; Increment position
    inc eax
    mov [esi + 4], eax
    
    ; Get character at new position
    movzx edx, byte [edi + eax]
    
    ; Set current_char
    mov [esi + 28], edx
    
    pop edi
    pop esi
    pop ebp
    ret

extern strlen

section .bss
ast_parse_ptr resd 1

; ===========================================
; PARSER SECTION
; ===========================================

section .text

; Arguments:
;   [esp+4]  = token_buffer
;   [esp+8]  = num_tokens
;   [esp+12] = ast_result_ptr (output: pointer to root AST node)
;   [esp+16] = ast_buffer (arena for AST nodes)
parser_parse:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx

    mov esi, [ebp + 8]      ; token_buffer
    mov ecx, [ebp + 12]     ; num_tokens
    mov edi, [ebp + 16]     ; ast_result_ptr
    mov ebx, [ebp + 20]     ; ast_buffer

    xor edx, edx            ; edx = token index
    mov [ast_parse_ptr], ebx ; ast arena pointer

    ; Call expr
    push edx                ; token index
    push esi                ; token_buffer
    call parser_expr
    add esp, 8

    mov [edi], eax          ; store AST root pointer

    pop ebx
    pop edi
    pop esi
    pop ebp
    ret

;-------------------------------------------
; AST Node Constructors
;-------------------------------------------

; eax = value, ebx = token_type
; returns: pointer to AST node in eax
parser_make_number:
    mov ecx, [ast_parse_ptr]
    mov dword [ecx], AST_NUMBER
    mov dword [ecx+4], eax
    mov dword [ecx+8], ebx
    mov eax, ecx
    add dword [ast_parse_ptr], AST_NUMBER_SIZE
    ret

; eax = left ptr, ebx = op_token, edx = right ptr
; returns: pointer to AST node in eax
parser_make_binop:
    mov ecx, [ast_parse_ptr]
    mov dword [ecx], AST_BINOP
    mov dword [ecx+4], eax
    mov dword [ecx+8], ebx
    mov dword [ecx+12], edx
    mov eax, ecx
    add dword [ast_parse_ptr], AST_BINOP_SIZE
    ret

; eax = op_token, ebx = node ptr
; returns: pointer to AST node in eax
parser_make_unaryop:
    mov ecx, [ast_parse_ptr]
    mov dword [ecx], AST_UNARYOP
    mov dword [ecx+4], eax
    mov dword [ecx+8], ebx
    mov eax, ecx
    add dword [ast_parse_ptr], AST_UNARYOP_SIZE
    ret

;-------------------------------------------
; Parser Functions
;-------------------------------------------

; parser_expr(token_buffer, token_index) -> eax = AST node ptr, edx = new token_index
parser_expr:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx

    mov esi, [ebp + 8]      ; token_buffer
    mov edx, [ebp + 12]     ; token_index

    ; left = parser_term(token_buffer, token_index)
    push edx
    push esi
    call parser_term
    add esp, 8
    mov ebx, eax            ; left node ptr
    mov edx, ecx            ; updated token_index

.expr_loop:
    mov eax, [esi + edx*8]  ; token type
    cmp eax, TT_PLUS
    je .plus
    cmp eax, TT_MINUS
    je .minus
    jmp .expr_done

.plus:
    inc edx
    ; right = parser_term(token_buffer, token_index)
    push edx
    push esi
    call parser_term
    add esp, 8
    mov edi, eax            ; right node ptr
    mov edx, ecx            ; updated token_index

    mov eax, ebx            ; left
    mov ebx, TT_PLUS
    mov edx, edi            ; right
    call parser_make_binop
    mov ebx, eax            ; new left = result
    jmp .expr_loop

.minus:
    inc edx
    push edx
    push esi
    call parser_term
    add esp, 8
    mov edi, eax
    mov edx, ecx

    mov eax, ebx
    mov ebx, TT_MINUS
    mov edx, edi
    call parser_make_binop
    mov ebx, eax
    jmp .expr_loop

.expr_done:
    mov eax, ebx            ; result node ptr
    mov ecx, edx            ; return updated token_index

    pop ebx
    pop edi
    pop esi
    pop ebp
    ret

; parser_term(token_buffer, token_index) -> eax = AST node ptr, ecx = new token_index
parser_term:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx

    mov esi, [ebp + 8]
    mov edx, [ebp + 12]

    ; left = parser_factor(token_buffer, token_index)
    push edx
    push esi
    call parser_factor
    add esp, 8
    mov ebx, eax
    mov edx, ecx

.term_loop:
    mov eax, [esi + edx*8]
    cmp eax, TT_MUL
    je .mul
    cmp eax, TT_DIV
    je .div
    jmp .term_done

.mul:
    inc edx
    push edx
    push esi
    call parser_factor
    add esp, 8
    mov edi, eax
    mov edx, ecx

    mov eax, ebx
    mov ebx, TT_MUL
    mov edx, edi
    call parser_make_binop
    mov ebx, eax
    jmp .term_loop

.div:
    inc edx
    push edx
    push esi
    call parser_factor
    add esp, 8
    mov edi, eax
    mov edx, ecx

    mov eax, ebx
    mov ebx, TT_DIV
    mov edx, edi
    call parser_make_binop
    mov ebx, eax
    jmp .term_loop

.term_done:
    mov eax, ebx
    mov ecx, edx

    pop ebx
    pop edi
    pop esi
    pop ebp
    ret

; parser_factor(token_buffer, token_index) -> eax = AST node ptr, ecx = new token_index
parser_factor:
    push ebp
    mov ebp, esp
    push esi
    push ebx

    mov esi, [ebp + 8]
    mov edx, [ebp + 12]

    mov eax, [esi + edx*8]  ; token type

    cmp eax, TT_PLUS
    je .unary_plus
    cmp eax, TT_MINUS
    je .unary_minus

    cmp eax, TT_INT
    je .int
    cmp eax, TT_FLOAT
    je .float

    cmp eax, TT_LPAREN
    je .lparen

    ; error: expected int/float/+/-
    mov eax, 0
    mov ecx, edx
    pop ebx
    pop esi
    pop ebp
    ret

.unary_plus:
    inc edx
    push edx
    push esi
    call parser_factor
    add esp, 8
    mov ebx, eax
    mov eax, TT_PLUS
    call parser_make_unaryop
    mov ecx, edx
    pop ebx
    pop esi
    pop ebp
    ret

.unary_minus:
    inc edx
    push edx
    push esi
    call parser_factor
    add esp, 8
    mov ebx, eax
    mov eax, TT_MINUS
    call parser_make_unaryop
    mov ecx, edx
    pop ebx
    pop esi
    pop ebp
    ret

.int:
    mov eax, [esi + edx*8 + 4] ; token value
    mov ebx, TT_INT
    call parser_make_number
    inc edx
    mov ecx, edx
    pop ebx
    pop esi
    pop ebp
    ret

.float:
    mov eax, [esi + edx*8 + 4]
    mov ebx, TT_FLOAT
    call parser_make_number
    inc edx
    mov ecx, edx
    pop ebx
    pop esi
    pop ebp
    ret

.lparen:
    inc edx
    push edx
    push esi
    call parser_expr
    add esp, 8
    mov ebx, eax
    mov edx, ecx
    mov eax, [esi + edx*8]
    cmp eax, TT_RPAREN
    jne .factor_error
    inc edx
    mov eax, ebx
    mov ecx, edx
    pop ebx
    pop esi
    pop ebp
    ret

.factor_error:
    mov eax, 0
    mov ecx, edx
    pop ebx
    pop esi
    pop ebp
    ret