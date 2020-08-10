default rel
%ifdef      MACOS
    %define     SYSCALL_WRITE   0x2000004
    %define     SYSCALL_EXIT    0x2000001
%else
    %define     SYSCALL_WRITE   1
    %define     SYSCALL_EXIT    60
%endif
extern printf
section .data
    fmt0 db "No input string provided", 10, 0
    fmt1 db "The input: %s", 10, 0
    fmt2 db "The input length: %d", 10, 0
    fmt3 db "%s", 10, 0
section .bss
    output resb 1000
    inputLen resb 1
section .text
    global main

main:
    push rbp
    mov rbp, rsp ;

    mov r9, rdi ; argc
    mov r10, rsi ; argv

    cmp r9, 1
    jbe bad_exit ; quit if argc <= 1

    mov r14, qword [ r10 + 8 ] ; store arg as r14 and use throughout

    mov rdi, r14 ; calculate length of input
    call pstrlen ; run internal function
    dec rax ; ignore the null-terminator at the end of the string
    mov [inputLen], rax ; store the string length as inputLen

    xor rax, rax
    mov rbx, r14
    mov rcx, [inputLen]
    mov r12, 0

    readloop:
        mov al, byte [rbx + r12] ; load next character
        push rax
        inc r12
        loop readloop

    xor rax, rax
    mov rbx, output
    mov rcx, [inputLen]
    mov r12, 0

    poploop:
        pop rax
        mov rdx, rax
        add rdx, 13 ; Shift right 13
        cmp rdx, 91 ; Shift back 26 if beyond Z
        jl .noshift
        sub rdx, 26
        .noshift:

        mov qword [rbx + r12], rdx
        inc r12 ; inc cursor

        loop poploop

    mov qword [rbx + r12], 0 ; Add null-terminator

    mov rdi, fmt3
    mov rsi, output
    mov rax, 0
    call printf

    mov rsp, rsp
    pop rbp
    mov rax, SYSCALL_EXIT
    mov rdi, 0
    syscall

bad_exit:
    mov rdi, fmt0
    mov rax, 0
    call printf
    mov rsp, rsp
    pop rbp
    mov rax, SYSCALL_EXIT
    mov rdi, 1
    syscall

pstrlen:
    push rbp;
    mov rbp, rsp
    mov rax, -16
    pxor xmm0, xmm0 ;
    .notfound:
        add rax, 16
        pcmpistri xmm0, [rdi + rax], 00001000b
        jnz .notfound
        add rax, rcx
        inc rax
    leave
    ret