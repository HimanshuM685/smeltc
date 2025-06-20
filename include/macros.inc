; =================================
; Token types constants
; =================================

%define TT_INT      1
%define TT_PLUS     2
%define TT_MINUS    3
%define TT_MUL      4
%define TT_DIV      5
%define TT_LPAREN   6
%define TT_RPAREN   7
%define TT_FLOAT    8
%define TT_EOF      9

; Legacy compatibility
%define TOKEN_INT     TT_INT
%define TOKEN_PLUS    TT_PLUS
%define TOKEN_MINUS   TT_MINUS
%define TOKEN_MULT    TT_MUL
%define TOKEN_DIV     TT_DIV
%define TOKEN_LPAREN  TT_LPAREN
%define TOKEN_RPAREN  TT_RPAREN
%define TOKEN_EOF     TT_EOF



; ================================
; Character constants
; ================================

%define CHAR_SPACE      32
%define CHAR_TAB        9
%define CHAR_NEWLINE    10
%define CHAR_DOT        46
%define CHAR_PLUS       43
%define CHAR_MINUS      45
%define CHAR_MUL        42
%define CHAR_DIV        47
%define CHAR_LPAREN     40
%define CHAR_RPAREN     41
%define CHAR_ZERO       48
%define CHAR_NINE       57



; Memory Sizes
%define MAX_TOKEN       1000
%define MAX_TEXT_LEN    4096
%define MAX_NUM_STR     32


; Error constants
%define ERR_NONE          0
%define ERR_ILLEGAL_CHAR  1


; Structure Sizes
%define POS_SIZE      20
%define TOKEN_SIZE    8
%define ERR_SIZE      20  ; 5ptr then 4*5 = 20


; isDigit 
%macro IS_DIGIT 2
  cmp %1, CHAR_ZERO
  jl %%not_digit
  cmp %1, CHAR_NINE
  jg %%not_digit
  mov %2, 1
  jmp %%end 
%%not_digit:
  mov %2, 0 
%%end:
%endmacro

%macro IS_WHITESPACE 2
  cmp %1, CHAR_SPACE
  je %%is_ws
  cmp %1, CHAR_TAB
  je %%is_ws
  mov %2, 0 
  jmp %%end
%%is_ws:
  mov %2, 1
%%end:
%endmacro


%macro ADV_POS 1
  push eax
  push ebx
  mov eax, %1
  inc dword [eax]     ; idx increment 
  inc dword [eax + 8] ; col increment


  mov ebx, [eax + 16]
  mov edx, [eax]
  cmp byte [ebx + edx -1], CHAR_NEWLINE
  jne %%no_newline

  inc dword [eax + 4]
  mov dword [eax + 8], 0 


%%no_newline:
  pop ebx
  pop eax
%endmacro

%macro SYS_WRITE 3
  mov eax, 4
  mov ebx, %1
  mov ecx, %2
  mov edx, %3
  int 0x80
%endmacro

%macro SYS_READ 3
  mov eax, 3
  mov ebx, %1
  mov ecx, %2
  mov edx, %3
  int 0x80
%endmacro

%macro SYS_EXIT 1
  mov eax, 1
  mov ebx, %1
  int 0x80
%endmacro

; =================================
; AST Node Types
; =================================

%define AST_NUMBER    1
%define AST_BINOP     2
%define AST_UNARYOP   3

; AST Node Sizes (in bytes)
%define AST_NUMBER_SIZE   12    ; type(4) + value(4) + token_type(4)
%define AST_BINOP_SIZE    16    ; type(4) + left(ptr 4) + op_token(4) + right(ptr 4)
%define AST_UNARYOP_SIZE  12    ; type(4) + op_token(4) + node(ptr 4)

; AST Buffer
%define AST_BUFFER_SIZE   4096
