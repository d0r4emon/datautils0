.thumb
.syntax unified
start:
// <- 
    push {r0-r4, lr}
    sub sp, #0x44
    ldr r4, [r3, #0x14]
    cmp r4, #0
    beq actually_eval
    ldr r3, vn_getpath
    mov r1, sp
    movs r0, #0x40
    add r2, sp, #0x40
    str r0, [r2]
    mov r0, r4
    blx r3
    cmp r0, #28
    beq enospc
    cmp r0, #0
    bne actually_eval
enospc:
    # that error's okay...

    mov r0, sp
    adr r1, string
    movs r2, #19 ;# "/private/var/mobile"
    ldr r3, memcmp
    blx r3
    cmp r0, #0
    bne allow

    mov r0, sp
    adr r1, string
    movs r2, #49 ;# "/private/var/mobile/Library/Preferences/com.apple"
    ldr r3, memcmp
    blx r3
    cmp r0, #0
    beq actually_eval

    mov r0, sp
    adr r1, string
    movs r2, #39 ;# "/private/var/mobile/Library/Preferences"
    ldr r3, memcmp
    blx r3
    cmp r0, #0
    bne actually_eval

allow:
    # it's not in /var/mobile but we have a path, let it through
    add sp, #0x44
    pop {r0}
    movs r1, #0
    str r1, [r0]
    movs r1, #0x18
    strb r1, [r0, #4]
    pop {r1-r4, pc}

actually_eval:
    add sp, #0x44
    ldr r0, [sp, #5*4]
    mov lr, r0
    ldr r1, orig_addr
    mov r9, r1

    pop {r0-r4}
    add sp, #4

#ifndef __ARM_ARCH_7A__
    bx pc
.align 2
.arm
#endif
    .long c_sb_evaluate_orig1
    .long c_sb_evaluate_orig2
    .long c_sb_evaluate_orig3
    .long c_sb_evaluate_orig4
    bx r9

.align 2
string: .ascii "/private/var/mobile/Library/Preferences/com.apple"
.align 2
orig_addr: .long c_sb_evaluate_jumpto
memcmp: .long c_memcmp
vn_getpath: .long c_vn_getpath
