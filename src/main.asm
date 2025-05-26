%include "macros.inc"
%include "lexer.inc"

section .data
  prompt        db 'shell> ', 0
  prompt_len    equ $ - prompt - 1
  newline       db 10, 0
  input_buffer  times MAX_TEXT_LEN db 0

  illegal_char_msg  db 'Illegal Character: ', 0
  error_at_msg      db 'File', 0
  line_msg          db ', line', 0
  
