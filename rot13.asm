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
    input db "HELLO WORLD", 0
    inputLen equ $ - input - 1
    fmt1 db "The input: %s", 10, 0
    fmt2 db "The Reverse-ROT13 string: %s", 10, 0
section .text
    global ENTRYPOINT

ENTRYPOINT:
    push rbp
    mov rbp, rsp ;

    mov rdi, fmt1
    mov rsi, input
    mov rax, 0
    call PRINTF

    xor rax, rax ; clear rax

    mov rbx, input
    mov rcx, inputLen
    mov r12, 0 ; r12 is counter

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