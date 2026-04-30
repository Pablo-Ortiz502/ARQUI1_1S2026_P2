.data
msg_orig_d:       .ascii  "\nMatriz original:\n"
msg_orig_d_len  = . - msg_orig_d

msg_err_cuad_d:   .ascii  "Error: la matriz debe ser cuadrada\n"
msg_err_cuad_d_len = . - msg_err_cuad_d

msg_det:          .ascii  "\nDeterminante = "
msg_det_len     = . - msg_det

msg_nl_d:         .ascii  "\n"
msg_nl_d_len    = . - msg_nl_d


.text
.global determinante

.extern print
.extern print_entero
.extern imprimir_matriz
.extern reservar_matriz
.extern liberar_matriz



// x0 = A, x1 = filas, x2 = cols
determinante:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // valida cuadrada
    cmp     x1, x2
    bne     d_error

    mov     x19, x0               // A original
    mov     x20, x1               // n

    // muestra A
    ldr     x1, =msg_orig_d
    mov     x2, #msg_orig_d_len
    bl      print
    mov     x0, x19
    mov     x1, x20
    mov     x2, x20
    bl      imprimir_matriz

    // copia A -> C
    mov     x0, x20
    mov     x1, x20
    bl      reservar_matriz
    mov     x22, x0               // C

    mul     x6, x20, x20
    mov     x7, #0
d_copia:
    cmp     x7, x6
    bge     d_copia_fin
    lsl     x8, x7, #3
    ldr     x9, [x19, x8]
    str     x9, [x22, x8]
    add     x7, x7, #1
    b       d_copia
d_copia_fin:

    mov     x28, #1               // signo (1 o -1)
    mov     x24, #1               // pivote anterior (inicia en 1)

    // bucle k = 0..n-1
    mov     x23, #0
d_k:
    cmp     x23, x20
    bge     d_resultado

    // C[k][k]
    mul     x6, x23, x20
    add     x6, x6, x23
    lsl     x6, x6, #3
    ldr     x25, [x22, x6]        // pivote actual

    // si pivote 0, busca fila para intercambiar
    cmp     x25, #0
    bne     d_no_swap

    // busca i > k con C[i][k] != 0
    add     x26, x23, #1
d_busca:
    cmp     x26, x20
    bge     d_cero                // no hay, det = 0

    mul     x7, x26, x20
    add     x7, x7, x23
    lsl     x7, x7, #3
    ldr     x9, [x22, x7]
    cmp     x9, #0
    bne     d_swap

    add     x26, x26, #1
    b       d_busca

d_swap:
    // intercambia fila k con fila i (x26)
    mov     x27, #0
d_swap_loop:
    cmp     x27, x20
    bge     d_swap_fin

    mul     x6, x23, x20
    add     x6, x6, x27
    lsl     x6, x6, #3
    mul     x7, x26, x20
    add     x7, x7, x27
    lsl     x7, x7, #3

    ldr     x9, [x22, x6]
    ldr     x10, [x22, x7]
    str     x10, [x22, x6]
    str     x9, [x22, x7]

    add     x27, x27, #1
    b       d_swap_loop
d_swap_fin:
    neg     x28, x28              // cambia signo
    // recarga pivote
    mul     x6, x23, x20
    add     x6, x6, x23
    lsl     x6, x6, #3
    ldr     x25, [x22, x6]

d_no_swap:
    // para i = k+1..n-1
    add     x26, x23, #1
d_i:
    cmp     x26, x20
    bge     d_sigk

    // C[i][k]
    mul     x6, x26, x20
    add     x6, x6, x23
    lsl     x6, x6, #3
    ldr     x27, [x22, x6]

    // para j = 0..n-1:
    //   C[i][j] = (C[i][j]*pivote - C[i][k]*C[k][j]) / pivote_anterior
    mov     x9, #0                // j (uso x9 como j)
d_j:
    cmp     x9, x20
    bge     d_sigi

    // C[i][j]
    mul     x6, x26, x20
    add     x6, x6, x9
    lsl     x6, x6, #3
    ldr     x10, [x22, x6]

    // C[k][j]
    mul     x7, x23, x20
    add     x7, x7, x9
    lsl     x7, x7, #3
    ldr     x11, [x22, x7]

    mul     x10, x10, x25         // C[i][j] * pivote
    mul     x11, x11, x27         // C[i][k] * C[k][j]
    sub     x10, x10, x11
    sdiv    x10, x10, x24         // / pivote_anterior

    str     x10, [x22, x6]

    add     x9, x9, #1
    b       d_j

d_sigi:
    add     x26, x26, #1
    b       d_i

d_sigk:
    mov     x24, x25              // pivote_anterior = pivote actual
    add     x23, x23, #1
    b       d_k

d_resultado:
    // det = C[n-1][n-1] * signo
    sub     x6, x20, #1
    mul     x7, x6, x20
    add     x7, x7, x6
    lsl     x7, x7, #3
    ldr     x9, [x22, x7]
    mul     x9, x9, x28

    ldr     x1, =msg_det
    mov     x2, #msg_det_len
    bl      print
    mov     x0, x9
    bl      print_entero
    ldr     x1, =msg_nl_d
    mov     x2, #msg_nl_d_len
    bl      print

    // libera C
    mov     x0, x22
    mov     x1, x20
    mov     x2, x20
    bl      liberar_matriz
    b       d_ret

d_cero:
    // determinante = 0
    ldr     x1, =msg_det
    mov     x2, #msg_det_len
    bl      print
    mov     x0, #0
    bl      print_entero
    ldr     x1, =msg_nl_d
    mov     x2, #msg_nl_d_len
    bl      print

    mov     x0, x22
    mov     x1, x20
    mov     x2, x20
    bl      liberar_matriz
    b       d_ret

d_error:
    ldr     x1, =msg_err_cuad_d
    mov     x2, #msg_err_cuad_d_len
    bl      print

d_ret:
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret                           // no retorna valor