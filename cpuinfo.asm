;compile commands -
;nasm -f elf32 cpuinfo.asm
;gcc -m32  cpuinfo.o -o cpuinfo

%include "checkflags.asm"

extern atoi
extern printf

section .data
str_too_few_args    db  "[!] Too few args. Usage ./cpuid <arg1>", 0xa, 0x0
str_cannot_set      db  "[!] CPUID instruction is not allowed on this processor", 0xa, 0x0
str_can_set         db  "[!] CPUID instruction is allowed on this processor", 0xa, 0x0
vendor_string       db  "[!] Vendor information:", 0xa, 0x9, "vendor string: %s", 0x9, "max CPUID value: 0x%x", 0x9, 0xa

section .rodata:

section .text

    global main

main:
    push    ebp
    mov     ebp,    esp

    cmp     DWORD[ebp+0x8], 2
    jb     .few_args
    ;converting argv[1] to a string
    mov     eax,    DWORD[ebp+0xC]
    add     eax,    4
    push    eax
    call    atoi
    mov     esi,    eax

    ;checking if ID bit is accassible
    push    0x00200000
    call    CheckCPUId
    add     esp,    0x4
    cmp     eax,    0x1
    jz      .flag_cannot_set
    push    str_can_set
    call    printf

.get_max_cpuid:
    xor     eax,    eax
    push    eax
    call    CPUId
    xor     ecx,    ecx

    .loop:
        cmp     ecx,    eax
        jz      .endloop
        push    ecx
        and     ecx,    esi
        cmp     ecx,    DWORD[esp]
        jne     .incr
        jmp     DWORD[.jmptab + ecx] 
        .incr:
            pop     ecx
            inc     ecx
            jmp     .loop

    .endloop:
        jmp     .return

    .A01:
        call    PrintVendorString
        jmp     .incr
    .A02:
        call    PrintVersionInfomaion
        jmp     .incr
    .A03:
        jmp     .incr
    .A04:
        jmp     .incr
    .A05:
        jmp     .incr
    .A06:
        jmp     .incr
    .A07:
        jmp     .incr
    .A08:   
        jmp     .incr
    .A09:
        jmp     .incr
    .A10:
        jmp     .incr
    .A11:
        jmp     .incr
    .A12:
        jmp     .incr

    .jmptab: 
        dd  .A01, .A02, .A03, .A04, .A05, .A06, .A07, .A08, .A09, .A10, .A11, .A12

    jmp     .return

.few_args:
    push    str_too_few_args
    call    printf
    add     esp,    0x4
    jmp     .return

.flag_cannot_set:
    push    str_cannot_set
    call    printf
    add     esp,    0x4

.return:
    mov     esp,    ebp
    pop     ebp
    ret

CPUId:
    push    ebp
    mov     ebp,    esp
    mov     eax,    [ebp+0x8]
    cpuid                               ;results stored in eax, ebx, ecx, edx
    mov     esp, ebp
    pop     ebp
    ret

;call cpuid with eax == 0
PrintVendorString:
    push    ebp
    mov     ebp,    esp

    push    0x0
    call    CPUId

    sub     esp,    24
    mov     DWORD[esp+0x4],     ebx
    mov     DWORD[esp+0x8],     edx
    mov     DWORD[esp+0xc],     ecx
    mov     BYTE[esp+0x10],     0xa
    mov     BYTE[esp+0x11],     0x0

    mov     DWORD[esp],     eax         ;max cpuid
    lea     eax,    DWORD[esp+0x4]
    push    eax
    push    vendor_string
    call    printf

    jmp     .return

.return:
    mov     esp,    ebp
    pop     ebp
    ret

PrintVersionInfomaion:
    push    ebp
    mov     ebp,    esp

    push    0x1
    call    CPUId

    push    str_can_set
    call    printf 

    mov     esp,    ebp
    pop     ebp
    ret
