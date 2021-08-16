strlen: push    ebp
        mov     ebp,    esp
        mov     eax,    [ebp+0x8]
        mov     ebx,    eax

.loop:  cmp     BYTE[eax], 0x0
        jz      .end
        inc     eax
        jmp     .loop

.end:   sub     eax,    ebx
        mov     esp,    ebp
        pop     ebp
        ret

atoi:   push    ebp
        mov     ebp,    esp
        push    edi
        push    esi

        mov     esi,    DWORD[ebp+0x8]
        xor     eax,    eax
        xor     ecx,    ecx

.loop:  xor     ebx,    ebx
        mov     bl,     BYTE[esi + ecx]
        cmp     bl,     48
        jb      .end
        cmp     bl,     57
        ja      .end
        sub     bl,     48
        add     eax,    ebx
        mov     ebx,    10
        mul     ebx
        inc     ecx
        jmp     .loop

.end:   cmp     ecx,    0
        je      .return
        mov     ebx,    10
        div     ebx

.return:pop     esi
        pop     edi
        mov     esp,    ebp
        pop     ebp
        ret