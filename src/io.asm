section .text
global print_hello

extern write

print_hello:
  mov rax, 1
  mov rdi, 1
  mov rsi, msg 
  mov rdx, msg_len
  syscall
  ret

section .data 
msg db "Hello from io.asm!", 0xA
msg_len equ $ - msg 
