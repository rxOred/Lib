;compile commands -
;nasm -f elf32 cpuinfo.asm
;gcc -m32  cpuinfo.o -o cpuinfo

%include "checkflags.asm"

extern printf

section .data
id_flag_false   db  "[!] CPUID instruction is not allowed on this processor", 0xa, 0x0
id_flag_true    db  "[!] CPUID instruction is allowed on this processor", 0xa, 0x0
vendor_info     db  "[!] Vendor information:", 0xa, 0x9, "vendor string: %s", 0x9, "max CPUID value: 0x%x", 0x9, 0xa

section .bss

section .text

    global main

main:
    push    ebp
    mov     ebp,    esp

    ;check id bit can be accessed
    call    CheckCPUId
    cmp     eax,    0x1
    jz      .print_err_msg
    push    id_flag_true
    call    printf

    ;check arg1 for flags
    call    PrintVendorString

    jmp     .return

.print_err_msg:
    push    id_flag_false
    call    printf
    add     esp,    0x4

.return:
    mov     esp,    ebp
    pop     ebp
    ret

CPUId:
    cpuid                               ;results stored in eax, ebx, ecx, edx
    ret

;call cpuid with eax == 0
PrintVendorString:
    push    ebp
    mov     ebp,    esp

    sub     esp,    24
    xor     eax,    eax
    call    CPUId

    mov     DWORD[esp+0x4],     ebx
    mov     DWORD[esp+0x8],     edx
    mov     DWORD[esp+0xc],     ecx
    mov     BYTE[esp+0x10],     0xa
    mov     BYTE[esp+0x11],     0x0

    mov     DWORD[esp],     eax         ;max cpuid
    lea     eax,    DWORD[esp+0x4]
    push    eax
    push    vendor_info
    call    printf

    jmp     .return

.return:
    mov     esp,    ebp
    pop     ebp
    ret
