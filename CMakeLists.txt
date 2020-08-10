cmake_minimum_required(VERSION 3.17)
project(mucking_around C)
project(math_test C)
project(rect ASM_NASM)
project(bottles ASM_NASM)
project(rot13 ASM_NASM)

SET(ASM_DIALECT "_NASM")
SET(CMAKE_ASM${ASM_DIALECT}_SOURCE_FILE_EXTENSIONS nasm;nas;asm)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_FLAGS, "${CMAKE_C_FLAGS} -mpreferred-stack-boundary=2 -fno-stack-protector")

add_executable(mucking_around main.c)
add_executable(math_test rect.c)

enable_language(ASM_NASM)

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

add_executable(bottles bottles.asm)
set_target_properties(bottles PROPERTIES LINKER_LANGUAGE NASM)

add_executable(rot13 rot13.asm)
set_target_properties(rot13 PROPERTIES LINKER_LANGUAGE NASM)

add_library(rect SHARED rect.asm)
set_target_properties(rect PROPERTIES LINKER_LANGUAGE NASM )

set(CMAKE_NASM_CREATE_SHARED_LIBRARY TRUE)
set(CMAKE_NASM_CREATE_STATIC_LIBRARY TRUE)

if (APPLE)
    # The NASM implementation in CMake is hokey, at best
    # it doesn't produce a dynamic lib unless you do a post command
    add_custom_command(TARGET rect
            POST_BUILD
            COMMAND gcc -dynamiclib -undefined suppress -flat_namespace *.o -o ${CMAKE_BINARY_DIR}/librect.dylib
            WORKING_DIRECTORY "${rect_BINARY_DIR}/CMakeFiles/rect.dir")
endif (APPLE)

add_dependencies(math_test rect)
target_link_libraries(math_test rect)
if (APPLE)
    target_link_libraries(rect System)
    target_link_libraries(bottles System)
    target_link_libraries(rot13 System)
endif (APPLE)