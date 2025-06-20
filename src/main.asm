%include "macros.inc"
%include "lexer.inc"

section .data
  prompt        db 'shell> ', 0
  prompt_len    equ $ - prompt - 1
  newline       db 10, 0
  input_buffer  times MAX_TEXT_LEN db 0

  ; Error 
  illegal_char_msg  db 'Illegal Character: ', 0
  error_at_msg      db 'File', 0
  line_msg          db ', line', 0

section .bss
  lexer_instance    resb 32
  token_buffer      resb MAX_TOKEN * TOKEN_SIZE
  error_buffer      resb ERR_SIZE
  temp_buffer       resb 256
  num_tokens        resd 1
  ast_buffer        resb AST_BUFFER_SIZE
  ast_result_ptr    resd 1

section .text
  global _start
  extern lexer_init, lexer_make_tokens, print_tokens, print_error, parser_parse
  extern strlen

_start:
  ; Main loop
.main_loop:
    ; Print prompt
    SYS_WRITE 1, prompt, prompt_len
    
    ; Read input
    SYS_READ 0, input_buffer, 255
    cmp eax, 0
    jle .exit
    
    ; Null terminate the input
    mov byte [input_buffer + eax - 1], 0  ; Remove newline
    
    ; Check for empty input
    cmp byte [input_buffer], 0
    je .main_loop
    
    ; Initialize lexer
    push input_buffer
    push lexer_instance
    call lexer_init
    add esp, 8
    
    ; Tokenize input
    push num_tokens
    push token_buffer
    push lexer_instance
    call lexer_make_tokens
    add esp, 12
    
    ; Check for errors
    cmp eax, ERR_NONE
    jne .handle_error
    
    ; Print tokens
    mov eax, [num_tokens]
    push eax
    push token_buffer
    call print_tokens
    add esp, 8
    
    jmp .main_loop

.handle_error:
    call print_error
    jmp .main_loop

.exit:
    SYS_EXIT 0

; Export symbols for the linker
global lexer_instance, token_buffer, temp_buffer, ast_buffer

remove_newline:
  push eax
  push ebx
  mov ebx, input_buffer
.loop:
  mov al, [ebx]
  cmp al, 10
  je .found_newline
  cmp al, 0
  je .remove_newline_done
  inc ebx
  jmp .loop
.found_newline:
  mov byte [ebx], 0
.remove_newline_done:
  pop ebx
  pop eax
  ret

.end_of_text:
  mov dword [ebx + 28], 0

.done:
  pop ecx
  pop ebx
  pop eax
  pop ebp
  ret

position_init:
  push ebp 
  mov ebp, esp
  push edi

  mov edi, [ebp + 8]
  mov eax, [ebp + 12]
  mov [edi], eax
  mov eax, [ebp + 16]
  mov [edi + 4], eax
  mov eax, [ebp + 20]
  mov [edi + 8], eax
  mov eax, [ebp + 24]
  mov [edi + 12], eax
  mov eax, [ebp + 28]
  mov [edi + 16], eax

  pop edi
  pop ebp
  ret
