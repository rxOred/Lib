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
above_max_value     db  "[!] Input value is above the maximum value that can be passed to cpuid instruction", 0xa, 0x0

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
                mov     esi,    eax                 ;esi = atoi(argv[1])
                cmp     esi,    0x1f
                jle     .loop_init      

.above_max:     push    above_max_value
                call    printf
                jmp     .return

.loop_init:     xor     ecx,    ecx
.loop:          cmp     ecx,    0x1f     
                jg      .endloop
                push    ecx
                and     ecx,    esi                 ;(ecx & atoi(argv[1])) ?
                cmp     ecx,    DWORD[esp]
                jne     .incr

                ;------------------------------;
                ;below code chunk is hardcoded.;
                ;try to implement a jump table ;
                ;to handle argv[1]             ;
                ;------------------------------;
                cmp     DWORD[esp],     0x0
                call    PrintVendorString
                jmp     .incr

                cmp     DWORD[esp],     0x1
                call    PrintVersionInfomaion
                jmp     .incr    
                
                cmp     DWORD[esp],     0x2
                call    PrintCacheTLBInformation
                jmp     .incr

                cmp     DWORD[esp],     0x3
                call    PrintProcessorSerial
                jmp     .incr

                cmp     DWORD[esp],     0x5
                call    PrintMONITOR
                jmp     .incr

                cmp     DWORD[esp],     0x6
                call    PrintThermalAndPowerInfomation
                jmp     .incr
               
                cmp     DWORD[esp],     0x9
                call    PrintDirectCacheAccessInformation
                jmp     .incr

                cmp     DWORD[esp],     0xa
                call    PrintArchitecturalPerformanceInformation
                jz      .incr

                cmp     DWORD[esp],     0xb
                call    PrintExtendedTopologyEnumInformation
                jz      .incr
            
                cmp     DWORD[esp],     0x15
                call    PrintTimeStampCounterInformation
                jz      .incr 

                cmp     DWORD[esp],     0x16
                call    PrintProcessorFreqInformation
                jz      .incr 

.incr:
                pop     ecx
                inc     ecx
                jmp     .loop

.endloop:       add     esp,    esi
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
