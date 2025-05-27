%include "../include/macros.inc"
%include "../include/lexer.inc"

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
  token_buffer      resb MAX_TOKENS * TOKEN_SIZE
  error_buffer      resb ERROR_SIZE
  temp_buffer       resb 256
  num_tokens        resb 1

section .text
  global _start
  extern lexer_init, lexer_make_tokens, print_tokens, print_error

_start:
  call main_loop

  SYS_EXIT 0

main_loop:
  SYS_WRITE 1, prompt, prompt_len
  SYS_READ 0, input_buffer, MAX_TEXT_LEN
  call remove_newline 
  cmp byte [input_buffer], 0
  je main_loop


  push input_buffer
  push lexer_instance
  call lexer_init
  add esp, 12

  push error_buffer
  push num_tokens
  push token_buffer
  push lexer_instance
  call lexer_make_tokens
  add esp, 16

  ; Error check
  cmp eax, ERR_NONE
  jne handle_error

  ; Print Tokens 
  push dword [num_tokens]
  push token_buffer
  call print_tokens
  add esp, 8

  jmp main_loop
