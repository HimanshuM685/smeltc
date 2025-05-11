%ifndef MACROS_INC
%define MACROS_INC

%define SYS_READ   0
%define SYS_WRITE  1
%define SYS_OPEN   2
%define SYS_CLOSE  3
%define SYS_EXIT   60

%define STDIN   0
%define STDOUT  1
%define STDERR  2

%define BUFFER_SIZE 1024

%define TOKEN_INT   1
%define TOKEN_PLUS  2
%define TOKEN_MINUS 3
%define TOKEN_MULT  4
%define TOKEN_DIV   5
%define TOKEN_EOF   6

%macro print 2
  mov rax, SYS_WRITE
  mov rdi, STDOUT
  mov rsi, %1
  mov rdx, %2
  syscall
%endmacro

%macro exit 1
mov rax, SYS_EXIT
  mov rdi, %1
  syscall
%endmacro
