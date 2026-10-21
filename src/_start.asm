; _start.asm - Multiboot2 entry point alignment & Stack initialization
bits 32

section .multiboot
align 8
multiboot_start:
    dd 0xe86250d6                 ; Multiboot2 magic number
    dd 0                          ; Architecture 0 (protected mode i386)
    dd multiboot_end - multiboot_start ; Header length
    dd -(0xe86250d6 + 0 + (multiboot_end - multiboot_start)) ; Checksum

    ; Required end tag
    dw 0
    dw 0
    dd 8
multiboot_end:

section .bootstrap_stack nobits
align 16
stack_bottom:
    resb 16384                    ; 16 KB stack allocation
stack_top:

section .text
global _start
extern kernel_main

_start:
    mov esp, stack_top            ; Point ESP register to the stack crown
    push eax                      ; Push Multiboot magic identifier token
    push ebx                      ; Push pointer to Multiboot information structure

    call kernel_main              ; Drop execution context down into bare-metal C++ kernel

.halt:
    hlt                           ; Indefinite CPU sleep fallthrough catch
    jmp .halt
