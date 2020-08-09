default rel
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
    fmtstr db "%d green bottles, hanging on the wall.",10, 0
    linkstr db "and if one green bottle, should accidentally fall. there'll be", 10, 0
    endstr db "there are no green bottles, hanging on the wall", 10, 0
    .len equ $ - linkstr - 1
    initial_bottles dq 10
section .bss
    bottles resq 1
section .text
    global _main

_main:
    push rbp ; prolog
    mov rbp, rsp

    xor rax, rax

    mov rax, [initial_bottles]
    mov [bottles], rax
bloop:
    mov rcx, [bottles]
    mov rdi, fmtstr
    mov rsi, rcx
    call _printf

    mov rcx, [bottles]
    mov rdi, fmtstr
    mov rsi, rcx
    call _printf

    mov rdi, linkstr
    call _printf

    mov rdx, [bottles]
    dec rdx
    mov [bottles], rdx
    cmp rdx, 0
    jg bloop
    jmp exit
exit:
mov rdi, endstr
    call _printf

    mov rsp, rbp ; epilog
    pop rbp

    mov rax, SYSCALL_EXIT
    mov rdi, 0
    syscall
