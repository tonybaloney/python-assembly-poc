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
    fmt2 db "The Reverse-ROT13 string: %s", 10, 0
section .bss
    input resq 1
    inputLen resq 1
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

    mov rdi, input
    call pstrlen
    mov [inputLen], rax

    xor rax, rax ; clear rax
    mov r12, 0 ; r12 is counter
    mov rbx, input
    mov rcx, inputLen

    pushloop:
        mov al, byte [rbx+r12] ; move char to stack
        push rax
        inc r12 ; inc position
        loop pushloop

    mov rbx, input
    mov rcx, inputLen
    mov r12, 0

    poploop:
        pop rax
        mov dl, al
        add dl, 13
        mov byte [rbx + r12], dl
        inc r12 ; inc cursor
        loop poploop

    mov byte [rbx + r12], 0 ; Add null-terminator

    mov rdi, fmt2
    mov rsi, input
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