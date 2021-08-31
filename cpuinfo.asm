;compile commands -
;nasm -f elf32 cpuinfo.asm
;gcc -m32  cpuinfo.o -o cpuinfo

%include "checkflags.asm"
%include "util.asm"

;extern atoi
extern printf

section .data
str_too_few_args    db  "[!] Too few args. Usage ./cpuid <arg1>", 0xa, 0x0
str_cannot_set      db  "[!] CPUID instruction is not allowed on this processor", 0xa, 0x0
str_can_set         db  "[!] CPUID instruction is allowed on this processor", 0xa, 0x0
vendor_string       db  "[!] Vendor information:", 0xa, 0x9, "vendor string: %s", 0x9, "max CPUID value: 0x%x", 0x9, 0xa

section .rodata:

section .text

    global main

main:           push    ebp
                mov     ebp,    esp

                cmp     DWORD[ebp+0x8], 2           ;if argc < 2
                jb     .few_args

.checkcpuid:    push    0x00200000
                call    CheckCPUId
                add     esp,    0x4
                cmp     eax,    0x1
                jz      .flag_cant_set
                push    str_can_set
                call    printf

.args:          mov     eax,    DWORD[ebp+0xC]
                add     eax,    4                   ;argv[1]
                push    eax
                call    atoi
                add     esp,    0x4
                mov     esi,    eax                 ;atoi(argv[1])

.max_cpuid:     xor     eax,    eax
                push    eax
                call    CPUId
                add     esp,    0x4

                xor     ecx,    ecx
.loop:          cmp     ecx,    esi
                jz      .endloop
                push    ecx
                and     ecx,    esi                 ;(ecx & atoi(argv[1])) ?
                cmp     ecx,    DWORD[esp]
                jne     .incr

                ;------------------------------;
                ;below code chunk is hardcoded.;
                ;try to implement a jump table ;
                ;to handle argv[1]             ;
                ;------------------------------;
                cmp     DWORD[esp],     0x1
                jz      .c1
                cmp     DWORD[esp],     0x2
                jz      .c2
                cmp     DWORD[esp],     0x3
                jz      .c3
                cmp     DWORD[esp],     0x4
                jz      .c4
                cmp     DWORD[esp],     0x5
                jz      .c5
                cmp     DWORD[esp],     0x6
                jz      .c6
                cmp     DWORD[esp],     0x7
                jz      .c7
                cmp     DWORD[esp],     0x8
                jz      .c8
                cmp     DWORD[esp],     0x9
                jz      .c9
                cmp     DWORD[esp],     0xa
                jz      .c10
                cmp     DWORD[esp],     0xb
                jz      .c11
                cmp     DWORD[esp],     0xc
                jz      .c12
                cmp     DWORD[esp],     0xd
                jz      .c13
                cmp     DWORD[esp],     0xe
                jz      .c14
                cmp     DWORD[esp],     0xf
                jz      .c15
                cmp     DWORD[esp],     0x10
                jz      .c16
                cmp     DWORD[esp],     0x11
                jz      .c17
                cmp     DWORD[esp],     0x12
                jz      .c18
                cmp     DWORD[esp],     0x13
                jz      .c19
                cmp     DWORD[esp],     0x14
                jz      .c20
                cmp     DWORD[esp],     0x15
                jz      .c21
                cmp     DWORD[esp],     0x16
                jz      .c22

.incr:
                pop     ecx
                inc     ecx
                jmp     .loop

;//section .rodata
;//.jmptab:        

;.endloop:      add     esp,    esi
                jmp    .return

.few_args:      push    str_too_few_args
                call    printf
                add     esp,    0x4
                jmp     .return

.flag_cant_set: push    str_cannot_set
                call    printf
                add     esp,    0x4

.return:        mov     esp,    ebp
                pop     ebp
                ret

CPUId:          push    ebp
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

.return:        mov     esp,    ebp
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
