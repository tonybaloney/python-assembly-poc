default rel
%ifdef      MACOS
    %define     ENTRYPOINT      _main
    %define     PRINTF          _printf
    %define     SYSCALL_WRITE   0x2000004
    %define     SYSCALL_EXIT    0x2000001
%else
    %define     ENTRYPOINT      start
    %define     PRINTF          printf
    %define     SYSCALL_WRITE   1
    %define     SYSCALL_EXIT    60
%endif
extern PRINTF
section .data
    fmt0 db "No input string provided", 10, 0
    fmt1 db "The input: %s", 10, 0
    fmt2 db "The input length: %d", 10, 0
    fmt3 db "The Reverse-ROT13 string: %s", 10, 0
section .bss
    input resq 1000
    output resq 1000
    inputLen resb 1
section .text
    global ENTRYPOINT

ENTRYPOINT:
    push rbp
    mov rbp, rsp ;

    mov r9, rdi ; argc
    mov r10, rsi ; argv

    cmp r9, 1
    jbe bad_exit ; quit if argc <= 1

    mov rdi, fmt1
    mov rsi, qword [ r10 + 8 ]
    mov [input], rsi
    mov rax, 0
    call PRINTF

    mov rdi, [input] ; calculate length of input
    call pstrlen ; run internal function
    dec rax ; ignore the null-terminator at the end of the string
    mov [inputLen], rax ; store the string length as inputLen

    mov rdi, fmt2
    mov rsi, [inputLen]
    mov rax, 0
    call PRINTF ; print length of test string

    xor rax, rax
    mov rbx, input
    mov rcx, [inputLen]
    mov r12, 0

    readloop:
        mov rax, qword [rbx + r12] ; load next character
        push rax
        inc r12
        loop readloop

    mov rbx, output
    mov rcx, [inputLen]
    mov r12, 0

    poploop:
        pop rax
        mov rdx, rax
        add rdx, 13 ; Shift right 13
        cmp rdx, 81 ; Shift back 26 if beyond Z
        jle .noshift
        sub rdx, 26
        .noshift:

        mov qword [rbx + r12], rdx
        inc r12 ; inc cursor

        loop poploop

    mov qword [rbx + r12], 0 ; Add null-terminator

    mov rdi, fmt3
    mov rsi, output
    mov rax, 0
    call PRINTF

mov rsp, rsp
pop rbp
ret

bad_exit:
    mov rdi, fmt0
    mov rax, 0
    call PRINTF
    mov rsp, rsp
    pop rbp
    ret

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