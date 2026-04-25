; PotatoOS stage-2 kernel
; Loaded by boot/boot.asm to 0x8000. Runs in 16-bit BIOS real mode.

BITS 16
ORG 0x8000

start:
    mov ax, 0x0003
    int 0x10
    mov si, banner
    call print
    mov si, help
    call print

shell:
    mov si, prompt
    call print
    call read_line
    call newline

    mov si, input
    mov di, cmd_help
    call streq
    jc .help
    mov si, input
    mov di, cmd_about
    call streq
    jc .about
    mov si, input
    mov di, cmd_clear
    call streq
    jc .clear
    mov si, input
    mov di, cmd_uptime
    call streq
    jc .uptime
    mov si, input
    mov di, cmd_reboot
    call streq
    jc .reboot

    mov si, unknown
    call print
    jmp shell

.help:
    mov si, help
    call print
    jmp shell
.about:
    mov si, about
    call print
    jmp shell
.clear:
    mov ax, 0x0003
    int 0x10
    mov si, banner
    call print
    jmp shell
.uptime:
    mov si, uptime
    call print
    jmp shell
.reboot:
    int 0x19

print:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x0F
    int 0x10
    jmp print
.done:
    ret

newline:
    mov al, 13
    mov ah, 0x0E
    int 0x10
    mov al, 10
    int 0x10
    ret

read_line:
    mov di, input
    xor cx, cx
.next:
    xor ah, ah
    int 0x16
    cmp al, 13
    je .enter
    cmp al, 8
    je .backspace
    cmp cx, 63
    jae .next
    stosb
    inc cx
    mov ah, 0x0E
    int 0x10
    jmp .next
.backspace:
    cmp cx, 0
    je .next
    dec di
    dec cx
    mov al, 8
    mov ah, 0x0E
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .next
.enter:
    xor al, al
    stosb
    ret

; Carry flag set when equal.
streq:
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .no
    test al, al
    jz .yes
    inc si
    inc di
    jmp .loop
.yes:
    stc
    ret
.no:
    clc
    ret

banner db 13,10
       db '  ____       _        _        ___  ____  ',13,10
       db ' |  _ \ ___ | |_ __ _| |_ ___ / _ \/ ___| ',13,10
       db ' | |_) / _ \| __/ _` | __/ _ \ | | \___ \ ',13,10
       db ' |  __/ (_) | || (_| | || (_) | |_| |___) |',13,10
       db ' |_|   \___/ \__\__,_|\__\___/ \___/|____/ ',13,10
       db 13,10,' PotatoOS v0.1.0 - two-stage bootable toy OS',13,10,0
help db 13,10,' commands: help, about, clear, uptime, reboot',13,10,0
about db 13,10,' PotatoOS boots from raw disk sectors without Linux, macOS, or DOS.',13,10
      db ' Stage 1 is a 512-byte bootloader; stage 2 is this shell kernel.',13,10,0
uptime db 13,10,' uptime: BIOS real-mode demo clock not wired yet. Roadmap item!',13,10,0
unknown db ' unknown command - type help',13,10,0
prompt db 13,10,'potato> ',0
cmd_help db 'help',0
cmd_about db 'about',0
cmd_clear db 'clear',0
cmd_uptime db 'uptime',0
cmd_reboot db 'reboot',0
input times 64 db 0
