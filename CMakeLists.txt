cmake_minimum_required(VERSION 3.17)
project(mucking_around C)
project(test ASM_NASM)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_FLAGS, "${CMAKE_C_FLAGS} -mpreferred-stack-boundary=2 -fno-stack-protector")

add_executable(mucking_around main.c)

enable_language(ASM_NASM)

set(CMAKE_NASM_LINK_EXECUTABLE "ld <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
set(CAN_USE_ASSEMBLER TRUE)

if (APPLE)
    set(CMAKE_ASM_NASM_OBJECT_FORMAT macho64)
    set(CMAKE_ASM_NASM_FLAGS "-DMACOS -l out.lst -g")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
endif (APPLE)

if (UNIX AND NOT APPLE)
    set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)
endif (UNIX AND NOT APPLE)

add_executable(test hello_world.asm)
set_target_properties(test PROPERTIES LINKER_LANGUAGE NASM)
if (APPLE)
    target_link_libraries(test System)
endif (APPLE)