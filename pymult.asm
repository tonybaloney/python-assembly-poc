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
        m_name:	resq	1 ; length of module name + 1
        m_doc:	resq	1
        m_size:	resb	1
        m_methods:	resb	6
        m_slots: resb	6
        m_traverse: resb	6
        m_clear: resb	6
        m_free: resb	6
    endstruc

section .bss
section .text

global PyInit_pymult
PyInit_pymult:
    extern PyModule_Create2
    section .data

        _moduledef:
            istruc moduledef
                at m_object_head_size, dq  1
                at m_object_head_type, dq 0x0  ; null
                at m_init, dq 0x0  ; null
                at m_index, dq 0 ; zero
                at m_copy, dq 0x0 ; null
                at m_name, dq modulename
                at m_doc, dq   docstring
                at m_size, db 2
                at m_methods, db  0
                at m_slots, db 0
                at m_traverse, db 0
                at m_clear, db 0
                at m_free, db 0
            iend
    section .text
        push rbp ; preserve stack pointer
        mov rbp, rsp

        lea rdi, qword[_moduledef] ; def PyModuleDef
        mov esi, 0x3f5 ; 1033 - module_api_version

        call PyModule_Create2

        mov rsp, rbp ; reinit stack pointer
        pop rbp
        ret