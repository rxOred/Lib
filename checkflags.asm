;arg1 = bitmask
CheckCPUId:
    push    ebp
    mov     ebp,    esp

    pushfd                              ;pushing eflags to the stack
    mov     edx,    DWORD[esp]
    mov     ebx,    DWORD[ebp+0x8]
    and     edx,    ebx
    cmp     edx,    ebx
    push    ebx,
    jne     .set_flag                   ;if id == 0, try setting the flag

.clear_flag:
    ;set id flag to 0
    call    ClearFlag                   ;else, try clear the flag
    add     esp,    0x4
    cmp     eax,    1                   ;check return value
    jmp     .return

.set_flag:
    ;set id flag to 1
    call    SetFlag
    add     esp,    0x4
    cmp     eax,    1                   ;check return value
    jmp     .return

.return:
    mov     esp,    ebp
    pop     ebp
    ret

ClearFlag:
    push    ebp
    mov     ebp,    esp
    push    esi
    push    edi

    pushfd
    mov     esi,    DWORD[esp]
    ;get this bit mask by negating ebp+0x8
    and     esi,    0xFFDFFFFF
    mov     DWORD[esp],     esi
    popfd

    pushfd
    mov     edi,    DWORD[esp]
    cmp     edi,    esi
    jnz     .failed
    xor     eax,    eax
    jmp     .return

.failed:
    mov     eax,    0x1

.return:
    pop     edi
    pop     esi
    mov     esp,    ebp
    pop     ebp
    ret

SetFlag:
    push    ebp
    mov     ebp,    esp
    push    esi
    push    edi

    pushfd
    mov     esi,    DWORD[esp]
    or      esi,    0x00200000          ;set id flag
    mov     DWORD[esp],     esi
    popfd

    pushfd
    mov     edi,    DWORD[esp]
    cmp     edi,    esi                 ;check if recently poped value of 
                                        ;eflags register is equal to the
                                        ;value of eflags with id flag set
                                        ;if so, we are done
    jnz     .failed
    xor     eax,    eax
    jmp     .return

.failed:
    mov     eax,    0x1

.return:
    pop     edi
    pop     esi
    mov     esp,    ebp
    pop     ebp
    ret
