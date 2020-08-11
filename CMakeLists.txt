cmake_minimum_required(VERSION 3.17)
project(pymult ASM_NASM)

SET(ASM_DIALECT "_NASM")
SET(CMAKE_ASM${ASM_DIALECT}_SOURCE_FILE_EXTENSIONS nasm;nas;asm)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_FLAGS, "${CMAKE_C_FLAGS} -mpreferred-stack-boundary=2")

enable_language(ASM_NASM)
set(BUILD_ARCH "-m64")
set(CMAKE_NASM_LINK_EXECUTABLE "ld <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
SET(CMAKE_ASM${ASM_DIALECT}_COMPILE_OBJECT "<CMAKE_ASM${ASM_DIALECT}_COMPILER> -o <OBJECT> <SOURCE>")

set(CAN_USE_ASSEMBLER TRUE)
set(BUILD_SHARED_LIBS TRUE)

if (APPLE)
    set(CMAKE_ASM_NASM_OBJECT_FORMAT macho64)
    set(CMAKE_ASM_NASM_FLAGS "-DMACOS -g --prefix _")
endif (APPLE)

if (UNIX AND NOT APPLE)
    set(CMAKE_ASM_NASM_OBJECT_FORMAT elf64)
endif (UNIX AND NOT APPLE)


add_library(pymult STATIC pymult.asm)
set_target_properties(pymult PROPERTIES LINKER_LANGUAGE NASM )

set(CMAKE_NASM_CREATE_SHARED_LIBRARY TRUE)
set(CMAKE_NASM_CREATE_STATIC_LIBRARY TRUE)

if (APPLE)
    # The NASM implementation in CMake is hokey, at best
    # it doesn't produce a dynamic lib unless you do a post command
    add_custom_command(TARGET pymult
            POST_BUILD
            COMMAND gcc -dynamiclib -undefined suppress -flat_namespace *.o -o ${CMAKE_BINARY_DIR}/pymult.so
            WORKING_DIRECTORY "${pymult_BINARY_DIR}/CMakeFiles/pymult.dir")
endif (APPLE)

target_link_libraries(pymult Python)
