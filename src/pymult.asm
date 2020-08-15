default rel
bits 64
%ifdef NOPIE
    %define PYARG_PARSETUPLE PyArg_ParseTuple
    %define PYLONG_FROMLONG PyLong_FromLong
    %define PYMODULE_CREATE2 PyModule_Create2
%else
    %define PYARG_PARSETUPLE PyArg_ParseTuple wrt ..plt
    %define PYLONG_FROMLONG PyLong_FromLong wrt ..plt
    %define PYMODULE_CREATE2 PyModule_Create2 wrt ..plt
%endif
section .data
    modulename db "pymult", 0
    docstring db "Simple Multiplication function", 0

    struc   moduledef
        ;pyobject header
        m_object_head_size: resq 1
        m_object_head_type: resq 1
        ;pymoduledef_base
        m_init: resq 1
        m_index: resq 1
        m_copy: resq 1
        ;moduledef
        m_name:	resq	1
        m_doc:	resq	1
        m_size:	resq	1
        m_methods:	resq	1
        m_slots: resq	1
        m_traverse: resq	1
        m_clear: resq	1
        m_free: resq	1
    endstruc

    struc methoddef
        ml_name:  resq 1
        ml_meth: resq 1
        ml_flags: resd 1
        ml_doc: resq 1
        ml_term: resq 1
        ml_term2: resq 1
    endstruc

section .bss
section .text

global PyInit_pymult
global PyMult_multiply

PyMult_multiply:
    ;
    ; pymult.multiply (a, b)
    ; Multiplies a and b
    ; Returns value as PyLong(PyObject*)
    extern PyLong_FromLong
    extern PyLong_AsLong
    extern PyArg_ParseTuple
    section .data
        parseStr db "LL", 0 ; convert arguments to Long, Long
    section .bss
        result resq 1 ; long result
        x resq 1      ; long input
        y resq 1      ; long input
    section .text
        push rbp ; preserve stack pointer
        mov rbp, rsp
        push rbx
        sub rsp, 0x18

        mov rdi, rsi                ; args
        lea rsi, [parseStr]    ; Parse args to LL
        xor ebx, ebx                ; clear the ebx
        lea rdx, [x]           ; set the address of x as the 3rd arg
        lea rcx, [y]           ; set the address of y as the 4th arg

        xor eax, eax                ; clear eax
        call PYARG_PARSETUPLE       ; Parse Args via C-API

        test eax, eax               ; if PyArg_ParseTuple is NULL, exit with error
        je badinput

        mov rax, [x]                ; multiply x and y
        imul qword[y]
        mov [result], rax

        mov edi, [result]           ; convert result to PyLong
        call PYLONG_FROMLONG

        mov rsp, rbp ; reinit stack pointer
        pop rbp
        ret

        badinput:
            mov rax, rbx
            add rsp, 0x18
            pop rbx
            pop rbp
            ret

PyInit_pymult:
    extern PyModule_Create2
    section .data
        method1name db "multiply", 0
        method1doc db "Multiply two values", 0

        _method1def:
            istruc methoddef
                at ml_name, dq method1name
                at ml_meth, dq PyMult_multiply
                at ml_flags, dd 0x0001 ; METH_VARARGS
                at ml_doc, dq 0x0
                at ml_term, dq 0x0 ; Method defs are terminated by two NULL values,
                at ml_term2, dq 0x0 ; equivalent to qword[0x0], qword[0x0]
            iend
        _moduledef:
            istruc moduledef
                at m_object_head_size, dq  1
                at m_object_head_type, dq 0x0  ; null
                at m_init, dq 0x0       ; null
                at m_index, dq 0        ; zero
                at m_copy, dq 0x0       ; null
                at m_name, dq modulename
                at m_doc, dq   docstring
                at m_size, dq 2
                at m_methods, dq _method1def
                at m_slots, dq 0    ; null- no slots
                at m_traverse, dq 0 ; null
                at m_clear, dq 0    ; null - no custom clear
                at m_free, dq 0     ; null - no custom free()
            iend
    section .text
        push rbp                    ; preserve stack pointer
        mov rbp, rsp

        lea rdi, [_moduledef]  ; load module def
        mov esi, 0x3f5              ; 1033 - module_api_version
        call PYMODULE_CREATE2       ; create module, leave return value in register as return result

        mov rsp, rbp ; reinit stack pointer
        pop rbp
        ret