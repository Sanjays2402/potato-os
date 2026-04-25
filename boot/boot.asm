; PotatoOS stage-1 bootloader
; BIOS loads this 512-byte sector at 0x7C00. It loads stage 2 at 0x8000.

BITS 16
ORG 0x7C00

KERNEL_LOAD equ 0x8000
KERNEL_SECTORS equ 8

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    mov [boot_drive], dl

    mov si, loading_msg
    call print

    mov bx, KERNEL_LOAD
    mov ah, 0x02
    mov al, KERNEL_SECTORS
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00
    mov dl, [boot_drive]
    int 0x13
    jc disk_error

    jmp 0x0000:KERNEL_LOAD

disk_error:
    mov si, disk_error_msg
    call print
    hlt
    jmp $

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

boot_drive db 0
loading_msg db 'PotatoOS bootloader: loading kernel...', 13, 10, 0
disk_error_msg db 'Disk read failed.', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55
