%include "../include/macros.inc"

section .data 
  newline_char    db 10, 0
  space_char      db ' ', 0

section .text
  global print_string, print_char, print_newline, print_number
  global read
