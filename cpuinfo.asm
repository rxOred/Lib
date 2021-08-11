;compile commands -
;nasm -f elf32 cpuinfo.asm
;gcc -m32  cpuinfo.o -o cpuinfo

%include "checkflags.asm"

extern printf

section .data
str_too_few_args    db  "[!] Too few args. Usage ./cpuid <arg1>", 0xa, 0x0
str_cannot_set      db  "[!] CPUID instruction is not allowed on this processor", 0xa, 0x0
str_can_set         db  "[!] CPUID instruction is allowed on this processor", 0xa, 0x0
vendor_string       db  "[!] Vendor information:", 0xa, 0x9, "vendor string: %s", 0x9, "max CPUID value: 0x%x", 0x9, 0xa

section .bss

section .text

    global main

main:
    push    ebp
    mov     ebp,    esp

    cmp     DWORD[ebp+0x8], 2
    jb     .few_args

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
        and     ecx,    DWORD[ebp+0x8]
        cmp     ecx,    DWORD[esp]
        call    PrintVendorString       ;replace with jump table index
        jmp     .loop

    .endloop:
        jmp     .return
 
    ;first get the max eax value 
    ;set ecx to that value
    ;loop through each
        ;compare if ecx == eax
        ;if yes break
        ;else push ecx, AND arg1 with ecx and store value in ecx
            ;compare ecx with [esp]
            ;if zero 
                ;jmp to corresponding label and call related subroutine
            ;else
                ;continue

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

    

    mov     esp,    ebp
    pop     ebp
    ret
