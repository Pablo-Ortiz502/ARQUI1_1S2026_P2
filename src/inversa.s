.data
msg_orig_inv:     .ascii  "\nMatriz original:\n"
msg_orig_inv_len = . - msg_orig_inv

msg_inversa:      .ascii  "\nMatriz inversa:\n"
msg_inversa_len = . - msg_inversa

msg_err_cuad_i:   .ascii  "Error: la matriz debe ser cuadrada\n"
msg_err_cuad_i_len = . - msg_err_cuad_i

msg_no_invertible: .ascii  "Error: matriz no invertible el determinante es 0\n"
msg_no_invertible_len = . - msg_no_invertible


.text
.global matriz_inversa

.extern print
.extern print_entero
.extern imprimir_matriz
.extern reservar_matriz
.extern liberar_matriz


// matriz inversa Gauss-Jordan
// x0 = A, x1 = filas, x2 = cols
matriz_inversa:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // valida cuadrada
    cmp     x1, x2
    bne     inv_error_cuad

    mov     x19, x0               // A
    mov     x20, x1               // n
    mov     x21, x1, lsl #1       // 2n (ancho de la aumentada)

    // muestra A
    ldr     x1, =msg_orig_inv
    mov     x2, #msg_orig_inv_len
    bl      print
    mov     x0, x19
    mov     x1, x20
    mov     x2, x20
    bl      imprimir_matriz

    // reserva M = [A | I] de n x 2n
    mov     x0, x20
    mov     x1, x21
    bl      reservar_matriz
    mov     x22, x0               // M

    // llena M: izquierda = A, derecha = I
    mov     x23, #0               // i
inv_init_fila:
    cmp     x23, x20
    bge     inv_init_fin

    mov     x24, #0               // j
inv_init_col:
    cmp     x24, x21
    bge     inv_init_sig

    // si j < n -> M[i][j] = A[i][j]
    cmp     x24, x20
    bge     inv_init_der

    // izquierda
    mul     x6, x23, x20
    add     x6, x6, x24
    lsl     x6, x6, #3
    ldr     x9, [x19, x6]

    mul     x7, x23, x21
    add     x7, x7, x24
    lsl     x7, x7, #3
    str     x9, [x22, x7]
    b       inv_init_next

inv_init_der:
    // derecha: identidad. col real en aumentada = j - n
    sub     x10, x24, x20
    cmp     x23, x10
    beq     inv_init_uno
    mov     x9, #0
    b       inv_init_guarda
inv_init_uno:
    mov     x9, #1
inv_init_guarda:
    mul     x7, x23, x21
    add     x7, x7, x24
    lsl     x7, x7, #3
    str     x9, [x22, x7]

inv_init_next:
    add     x24, x24, #1
    b       inv_init_col

inv_init_sig:
    add     x23, x23, #1
    b       inv_init_fila

inv_init_fin:
    // Gauss-Jordan sobre M
    mov     x23, #0               // k
inv_k:
    cmp     x23, x20
    bge     inv_norm

    // pivote = M[k][k]
    mul     x6, x23, x21
    add     x6, x6, x23
    lsl     x6, x6, #3
    ldr     x24, [x22, x6]

    cmp     x24, #0
    beq     inv_no_inv

    // elimina en cada fila i != k
    mov     x25, #0               // i
inv_i:
    cmp     x25, x20
    bge     inv_sigk

    cmp     x25, x23
    beq     inv_sigi

    // factor = M[i][k]
    mul     x6, x25, x21
    add     x6, x6, x23
    lsl     x6, x6, #3
    ldr     x26, [x22, x6]

    cmp     x26, #0
    beq     inv_sigi

    // para j = 0..2n-1: M[i][j] = M[i][j]*pivote - M[i][k]*M[k][j]
    mov     x27, #0
inv_j:
    cmp     x27, x21
    bge     inv_sigi

    mul     x6, x25, x21
    add     x6, x6, x27
    lsl     x6, x6, #3
    ldr     x9, [x22, x6]

    mul     x7, x23, x21
    add     x7, x7, x27
    lsl     x7, x7, #3
    ldr     x10, [x22, x7]

    mul     x9, x9, x24
    mul     x10, x10, x26
    sub     x9, x9, x10
    str     x9, [x22, x6]

    add     x27, x27, #1
    b       inv_j

inv_sigi:
    add     x25, x25, #1
    b       inv_i

inv_sigk:
    add     x23, x23, #1
    b       inv_k

inv_norm:
    // normaliza: divide cada fila i por M[i][i]
    mov     x23, #0
inv_n_fila:
    cmp     x23, x20
    bge     inv_extrae

    mul     x6, x23, x21
    add     x6, x6, x23
    lsl     x6, x6, #3
    ldr     x24, [x22, x6]

    cmp     x24, #0
    beq     inv_n_sig

    mov     x25, #0
inv_n_col:
    cmp     x25, x21
    bge     inv_n_sig

    mul     x6, x23, x21
    add     x6, x6, x25
    lsl     x6, x6, #3
    ldr     x9, [x22, x6]
    sdiv    x9, x9, x24
    str     x9, [x22, x6]

    add     x25, x25, #1
    b       inv_n_col

inv_n_sig:
    add     x23, x23, #1
    b       inv_n_fila

inv_extrae:
    // reserva R de n x n para guardar la mitad derecha de M
    mov     x0, x20
    mov     x1, x20
    bl      reservar_matriz
    mov     x28, x0               // R = inversa

    mov     x23, #0
inv_e_fila:
    cmp     x23, x20
    bge     inv_e_fin

    mov     x24, #0
inv_e_col:
    cmp     x24, x20
    bge     inv_e_sig

    // col en M = x24 + n
    add     x10, x24, x20
    mul     x7, x23, x21
    add     x7, x7, x10
    lsl     x7, x7, #3
    ldr     x9, [x22, x7]

    mul     x6, x23, x20
    add     x6, x6, x24
    lsl     x6, x6, #3
    str     x9, [x28, x6]

    add     x24, x24, #1
    b       inv_e_col

inv_e_sig:
    add     x23, x23, #1
    b       inv_e_fila

inv_e_fin:
    // muestra R
    ldr     x1, =msg_inversa
    mov     x2, #msg_inversa_len
    bl      print
    mov     x0, x28
    mov     x1, x20
    mov     x2, x20
    bl      imprimir_matriz

    // libera R y M
    mov     x0, x28
    mov     x1, x20
    mov     x2, x20
    bl      liberar_matriz
    mov     x0, x22
    mov     x1, x20
    mov     x2, x21
    bl      liberar_matriz
    b       inv_ret

inv_no_inv:
    ldr     x1, =msg_no_invertible
    mov     x2, #msg_no_invertible_len
    bl      print
    mov     x0, x22
    mov     x1, x20
    mov     x2, x21
    bl      liberar_matriz
    b       inv_ret

inv_error_cuad:
    ldr     x1, =msg_err_cuad_i
    mov     x2, #msg_err_cuad_i_len
    bl      print

inv_ret:
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret                           // no retorna valor