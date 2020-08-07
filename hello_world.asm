%ifdef      MACOS
    %define     ENTRYPOINT      _main
    %define     SYSCALL_WRITE   0x2000004
    %define     SYSCALL_EXIT    0x2000001
%else
    %define     ENTRYPOINT      start
    %define     SYSCALL_WRITE   1
    %define     SYSCALL_EXIT    60
%endif
extern _printf
section .data
    msg db "hello, world", 0x0A
    .len equ $ - msg
    NL db 0xa
    meaningoflife db 42
    fmtstr db "The meaning of life is %d", 10, 0
section .bss
    letters resb 26
section .text
    global _main
_main:
    push rbp ; prolog
    mov rbp, rsp

    mov rax, SYSCALL_WRITE
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg.len
    syscall

    mov rax, 0
    mov rdi, fmtstr
    mov rsi, meaningoflife
    call _printf

    mov rsp, rbp ; epilog
    pop rbp

    mov rax, SYSCALL_EXIT
    mov rdi, 0
    syscall
