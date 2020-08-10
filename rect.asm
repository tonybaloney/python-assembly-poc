default rel
section .data
section .bss
section .text

global rarea
rarea:
    section .text
        push rbp
        mov rbp, rsp
        mov rax, rdi
        imul rsi
        leave
        ret
