.data
msg_orig_j:       .ascii  "\nMatriz original:\n"
msg_orig_j_len  = . - msg_orig_j

msg_jordan:       .ascii  "\nMatriz reducida (Gauss-Jordan):\n"
msg_jordan_len  = . - msg_jordan

msg_no_inv:       .ascii  "\nNota: pivote cero encontrado, la matriz puede no ser reducible completamente\n"
msg_no_inv_len  = . - msg_no_inv


.text
.global metodo_jordan

.extern print
.extern print_entero
.extern imprimir_matriz
.extern reservar_matriz
.extern liberar_matriz


// metodo Gauss-Jordan
// x0 = A, x1 = filas, x2 = cols
metodo_jordan:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    mov     x19, x0               // A original
    mov     x20, x1               // filas
    mov     x21, x2               // cols

    // muestra A
    ldr     x1, =msg_orig_j
    mov     x2, #msg_orig_j_len
    bl      print
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // reserva copia C de A
    mov     x0, x20
    mov     x1, x21
    bl      reservar_matriz
    mov     x22, x0               // C

    // copia A -> C
    mul     x6, x20, x21
    mov     x7, #0
j_copia:
    cmp     x7, x6
    bge     j_copia_fin
    lsl     x8, x7, #3
    ldr     x9, [x19, x8]
    str     x9, [x22, x8]
    add     x7, x7, #1
    b       j_copia
j_copia_fin:

    // bucle por columna pivote k
    mov     x23, #0               // k
j_k:
    cmp     x23, x20
    bge     j_norm
    cmp     x23, x21
    bge     j_norm

    // pivote = C[k][k]
    mul     x6, x23, x21
    add     x6, x6, x23
    lsl     x6, x6, #3
    ldr     x24, [x22, x6]

    // si pivote = 0, salta
    cmp     x24, #0
    beq     j_pivote_cero

    // elimina en TODAS las filas i != k
    mov     x25, #0               // i
j_i:
    cmp     x25, x20
    bge     j_sigk

    // si i == k, salta
    cmp     x25, x23
    beq     j_sigi

    // factor = C[i][k]
    mul     x6, x25, x21
    add     x6, x6, x23
    lsl     x6, x6, #3
    ldr     x26, [x22, x6]

    // si C[i][k] = 0, salta
    cmp     x26, #0
    beq     j_sigi

    // para cada j: C[i][j] = C[i][j]*pivote - C[i][k]*C[k][j]
    mov     x27, #0
j_j:
    cmp     x27, x21
    bge     j_sigi

    // C[i][j]
    mul     x6, x25, x21
    add     x6, x6, x27
    lsl     x6, x6, #3
    ldr     x9, [x22, x6]

    // C[k][j]
    mul     x7, x23, x21
    add     x7, x7, x27
    lsl     x7, x7, #3
    ldr     x10, [x22, x7]

    mul     x9, x9, x24
    mul     x10, x10, x26
    sub     x9, x9, x10
    str     x9, [x22, x6]

    add     x27, x27, #1
    b       j_j

j_sigi:
    add     x25, x25, #1
    b       j_i

j_pivote_cero:
    ldr     x1, =msg_no_inv
    mov     x2, #msg_no_inv_len
    bl      print

j_sigk:
    add     x23, x23, #1
    b       j_k

j_norm:
    // normaliza: divide cada fila por su pivote (si divide exacto)
    mov     x23, #0               // i
j_n_fila:
    cmp     x23, x20
    bge     j_imp
    cmp     x23, x21
    bge     j_imp

    // pivote = C[i][i]
    mul     x6, x23, x21
    add     x6, x6, x23
    lsl     x6, x6, #3
    ldr     x24, [x22, x6]

    cmp     x24, #0
    beq     j_n_sig               // pivote 0, no normaliza

    // divide toda la fila por pivote
    mov     x25, #0               // j
j_n_col:
    cmp     x25, x21
    bge     j_n_sig

    mul     x6, x23, x21
    add     x6, x6, x25
    lsl     x6, x6, #3
    ldr     x9, [x22, x6]

    sdiv    x9, x9, x24
    str     x9, [x22, x6]

    add     x25, x25, #1
    b       j_n_col

j_n_sig:
    add     x23, x23, #1
    b       j_n_fila

j_imp:
    // muestra resultado
    ldr     x1, =msg_jordan
    mov     x2, #msg_jordan_len
    bl      print
    mov     x0, x22
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // libera C
    mov     x0, x22
    mov     x1, x20
    mov     x2, x21
    bl      liberar_matriz

    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret                           // no retorna valor