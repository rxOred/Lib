strlen:
    push    ebp
    mov     ebp,    esp
    mov     eax,    [ebp+0x8]
    mov     ebx,    eax

.loop:
    cmp     BYTE[eax], 0x0
    jz      .end
    inc     eax
    jmp     .loop

.end:
    sub     eax,    ebx
    mov     esp,    ebp
    pop     ebp
    ret
