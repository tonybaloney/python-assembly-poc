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
    fmtstr db "The meaning of life is %10d",10, 0
section .text
    global _main
_main:
    push rbp ; prolog
    mov rbp, rsp

    mov rax, 0
    mov rdi, fmtstr
    mov rsi, 42
    call _printf

    mov rsp, rbp ; epilog
    pop rbp

    mov rax, SYSCALL_EXIT
    mov rdi, 0
    syscall
