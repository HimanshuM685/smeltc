; ===========================================
; IO.ASM
; ===========================================

%include "macros.inc"

section .data
    newline_char    db 10, 0
    space_char      db ' ', 0
    
section .text
    global print_string, print_char, print_newline, print_number
    global read_line, string_length, string_copy, string_compare
    global strlen

print_string:
    push ebp
    mov ebp, esp
    push eax
    push ebx
    push ecx
    push edx
    
    mov eax, [ebp + 8]      ; string address
    call string_length      ; get length in eax
    mov edx, eax            ; length for sys_write
    mov ecx, [ebp + 8]      ; string address
    
    SYS_WRITE 1, ecx, edx
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop ebp
    ret

print_char:
    push ebp
    mov ebp, esp
    sub esp, 4              ; space for character
    
    mov eax, [ebp + 8]      ; get character
    mov [ebp - 4], al       ; store in local buffer
    
    lea eax, [ebp - 4]      ; address of character
    SYS_WRITE 1, eax, 1
    
    add esp, 4
    pop ebp
    ret

; Print newline
print_newline:
    push 10                 ; newline character
    call print_char
    add esp, 4
    ret

print_number:
    push ebp
    mov ebp, esp
    sub esp, 16             ; buffer for digits
    push esi
    push edi
    push ebx
    
    mov eax, [ebp + 8]      ; number to print
    lea edi, [ebp - 1]      ; end of buffer
    mov esi, edi            ; keep track of start
    
    test eax, eax
    jns .positive
    neg eax
    push '-'
    call print_char
    add esp, 4
    
.positive:
    mov ebx, 10
.convert_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz .convert_loop
    
    ; Print the string
    inc edi
    mov ecx, esi
    sub ecx, edi
    inc ecx                 ; length
    
    SYS_WRITE 1, edi, ecx
    
    pop ebx
    pop edi
    pop esi
    add esp, 16
    pop ebp
    ret

read_line:
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    
    mov ecx, [ebp + 8]      ; buffer address
    mov edx, [ebp + 12]     ; buffer size
    
    SYS_READ 0, ecx, edx
    
    cmp eax, 0
    jle .read_done
    
    mov ebx, ecx
    add ebx, eax
    dec ebx
    cmp byte [ebx], 10
    jne .read_done
    mov byte [ebx], 0       ; replace with null terminator
    dec eax
    
.read_done:
    pop edx
    pop ecx
    pop ebx
    pop ebp
    ret

string_length:
    push ebx
    push ecx
    
    mov ebx, eax            ; string address
    xor ecx, ecx            ; counter
    
.length_loop:
    cmp byte [ebx + ecx], 0
    je .length_done
    inc ecx
    jmp .length_loop
    
.length_done:
    mov eax, ecx
    
    pop ecx
    pop ebx
    ret

string_copy:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push eax
    
    mov esi, [ebp + 8]      ; source
    mov edi, [ebp + 12]     ; destination
    
.copy_loop:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    test al, al
    jnz .copy_loop
    
    pop eax
    pop edi
    pop esi
    pop ebp
    ret

string_compare:
    push ebp
    mov ebp, esp
    push esi
    push edi
    
    mov esi, [ebp + 8]
    mov edi, [ebp + 12]
    
.compare_loop:
    mov al, [esi]
    mov ah, [edi]
    cmp al, ah
    jne .not_equal
    
    test al, al             ; end of string?
    jz .equal
    
    inc esi
    inc edi
    jmp .compare_loop
    
.equal:
    xor eax, eax
    jmp .compare_done
    
.not_equal:
    mov eax, 1
    
.compare_done:
    pop edi
    pop esi
    pop ebp
    ret

string_to_int:
    push ebp
    mov ebp, esp
    push esi
    push ebx
    push ecx
    
    mov esi, [ebp + 8]
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
    
    ; Check for negative sign
    cmp byte [esi], '-'
    jne .parse_digits
    inc esi
    mov ebx, 1
    
.parse_digits:
    mov cl, [esi]
    test cl, cl
    jz .convert_done
    
    cmp cl, '0'
    jl .convert_done
    cmp cl, '9'
    jg .convert_done
    
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    
    inc esi
    jmp .parse_digits
    
.convert_done:
    ; Apply sign
    test ebx, ebx
    jz .positive_result
    neg eax
    
.positive_result:
    pop ecx
    pop ebx
    pop esi
    pop ebp
    ret

int_to_string:
    push ebp
    mov ebp, esp
    push esi
    push edi
    push ebx
    push ecx
    push edx
    
    mov eax, [ebp + 8]
    mov edi, [ebp + 12]
    mov esi, edi
    
    test eax, eax
    jns .positive_number
    neg eax
    mov byte [edi], '-'
    inc edi
    
.positive_number:
    test eax, eax
    jnz .convert_digits
    mov byte [edi], '0'
    inc edi
    jmp .null_terminate
    
.convert_digits:
    mov ecx, edi
    mov ebx, 10
    
.digit_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    inc edi
    test eax, eax
    jnz .digit_loop
    
    ; Reverse the digits
    dec edi
    mov eax, ecx
    
.reverse_loop:
    cmp eax, edi
    jge .null_terminate
    
    mov bl, [eax]
    mov dl, [edi]
    mov [eax], dl
    mov [edi], bl
    
    inc eax
    dec edi
    jmp .reverse_loop
    
.null_terminate:
    mov byte [edi], 0
    
    mov eax, edi
    sub eax, esi
    
    pop edx
    pop ecx
    pop ebx
    pop edi
    pop esi
    pop ebp
    ret

strlen:
    push ebp
    mov ebp, esp
    push edi
    push ecx
    
    mov edi, [ebp + 8]  ; string pointer
    xor ecx, ecx        ; counter
    
.strlen_loop:
    cmp byte [edi + ecx], 0
    je .strlen_done
    inc ecx
    jmp .strlen_loop
    
.strlen_done:
    mov eax, ecx
    
    pop ecx
    pop edi
    pop ebp
    ret