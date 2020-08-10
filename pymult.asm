default rel
section .data
    modulename db "pymult", 0
    docstring db "Simple Multiplication function", 0

    struc   moduledef
        ;moduledef_base
        m_object_head_size: resq 1
        m_object_head_type: resq 1
        m_init: resq 1
        m_index: resq 1
        m_copy: resq 1
        ;moduledef
        m_name:	resq	1
        m_doc:	resq	1
        m_size:	resq	1
        m_methods:	resq	1
        m_slots: resb	6
        m_traverse: resb	6
        m_clear: resb	6
        m_free: resb	6
    endstruc

    struc methoddef
        ml_name:  resq 1
        ml_meth: resq 1
        ml_flags: resb 1
        ml_doc: resq 1
    endstruc

section .bss
section .text

global PyInit_pymult
global PyMult_multiply

PyMult_multiply:
    section .text
        push rbp ; preserve stack pointer
        mov rbp, rsp

        mov rsp, rbp ; reinit stack pointer
        pop rbp
        ret

PyInit_pymult:
    extern PyModule_Create2
    section .data
        method1name db "multiply", 0
        method1doc db "Multiply two values", 0
        _moduledef:
            istruc moduledef
                at m_object_head_size, dq  1
                at m_object_head_type, dq 0x0  ; null
                at m_init, dq 0x0  ; null
                at m_index, dq 0 ; zero
                at m_copy, dq 0x0 ; null
                at m_name, dq modulename
                at m_doc, dq   docstring
                at m_size, dq 2
                at m_methods, dq 0x0
                at m_slots, db 0
                at m_traverse, db 0
                at m_clear, db 0
                at m_free, db 0
            iend
        _method1def:
            istruc methoddef
                at ml_name, dq method1name
                at ml_meth, dq 0x0
                at ml_flags, db 0x0001 ; METH_VARARGS
                at ml_doc, dq method1doc
            iend

    section .text
        push rbp ; preserve stack pointer
        mov rbp, rsp

        lea rdi, qword[_moduledef] ; def PyModuleDef

        ;mov r10, qword[_method1def]
        ;mov [_moduledef + m_methods], r10

        mov esi, 0x3f5 ; 1033 - module_api_version

        call PyModule_Create2

        mov rsp, rbp ; reinit stack pointer
        pop rbp
        ret