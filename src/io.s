.data
.bss
.align 3
input_buf:      .skip 32          // buffer entrada
.align 3
out_buf:        .skip 32          // buffer salida

.text
.global print
.global leer_entero
.global print_entero

// imprime cadena
// x1=ptr, x2=len
print:
    mov     x0, #1
    mov     x8, #64
    svc     #0
    ret


// lee entero
// retorna x0
leer_entero:
    stp     x29, x30, [sp, #-16]!

    mov     x0, #0
    ldr     x1, =input_buf
    mov     x2, #32
    mov     x8, #63
    svc     #0

    mov     x2, x0
    ldr     x1, =input_buf

    mov     x0, #0                // acumulador
    mov     x3, #0                // indice
    mov     x5, #10
atoi_loop:
    cmp     x3, x2
    bge     atoi_fin
    ldrb    w4, [x1, x3]
    cmp     w4, #'0'
    blt     atoi_fin
    cmp     w4, #'9'
    bgt     atoi_fin
    sub     w4, w4, #'0'
    mul     x0, x0, x5
    add     x0, x0, x4
    add     x3, x3, #1
    b       atoi_loop
atoi_fin:
    ldp     x29, x30, [sp], #16
    ret                           // x0 = valor


// imprime entero
// x0 = valor
print_entero:
    stp     x29, x30, [sp, #-16]!

    ldr     x1, =out_buf
    add     x1, x1, #31
    mov     x2, #0
    mov     x3, #10

    // caso 0
    cmp     x0, #0
    bne     itoa_loop
    mov     w4, #'0'
    strb    w4, [x1]
    mov     x2, #1
    b       itoa_print

itoa_loop:
    cmp     x0, #0
    beq     itoa_print
    udiv    x4, x0, x3
    msub    x5, x4, x3, x0
    add     w5, w5, #'0'
    sub     x1, x1, #1
    strb    w5, [x1]
    mov     x0, x4
    add     x2, x2, #1
    b       itoa_loop

itoa_print:
    mov     x0, #1
    mov     x8, #64
    svc     #0

    ldp     x29, x30, [sp], #16
    ret