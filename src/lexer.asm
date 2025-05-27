%include "../include/macros.inc"

section .data
  digits_str    db '0123456789', 0
  illegal_msg   db 'Illegal Character', 0

section .text 
  global lexer_make_tokens, lexer_make_number, print_tokens, print_error
  global token_create, error_create, is_digit, is_whitespace

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
  je .skip whitespace

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
