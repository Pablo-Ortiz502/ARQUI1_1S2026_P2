.data
msg_orig_g:       .ascii  "\nMatriz original:\n"
msg_orig_g_len  = . - msg_orig_g

msg_gauss:        .ascii  "\nMatriz triangular (Gauss):\n"
msg_gauss_len   = . - msg_gauss

msg_paso:         .ascii  "\nPaso "
msg_paso_len    = . - msg_paso

msg_dospts:       .ascii  ":\n"
msg_dospts_len  = . - msg_dospts


.text
.global metodo_gauss

.extern print
.extern print_entero
.extern imprimir_matriz
.extern reservar_matriz
.extern liberar_matriz


// metodo de Gauss (sin fracciones)
// x0 = A, x1 = filas, x2 = cols
metodo_gauss:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    mov     x19, x0               // A original (no se toca)
    mov     x20, x1               // filas
    mov     x21, x2               // cols

    // muestra A
    ldr     x1, =msg_orig_g
    mov     x2, #msg_orig_g_len
    bl      print
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // reserva copia C de A
    mov     x0, x20
    mov     x1, x21
    bl      reservar_matriz
    mov     x22, x0               // C (copia de trabajo)

    // copia A -> C
    mul     x6, x20, x21          // total celdas
    mov     x7, #0                // indice
copia_loop:
    cmp     x7, x6
    bge     copia_fin
    lsl     x8, x7, #3
    ldr     x9, [x19, x8]
    str     x9, [x22, x8]
    add     x7, x7, #1
    b       copia_loop
copia_fin:

    // bucle por columna pivote k
    mov     x23, #0               // k
g_k:
    cmp     x23, x20
    bge     g_imp                 // si k >= filas, termina
    cmp     x23, x21
    bge     g_imp                 // si k >= cols, termina

    // pivote = C[k][k]
    mul     x6, x23, x21
    add     x6, x6, x23
    lsl     x6, x6, #3
    ldr     x24, [x22, x6]        // x24 = pivote

    // si pivote = 0, salta esta columna
    cmp     x24, #0
    beq     g_sigk

    // para cada fila i = k+1 .. filas-1
    add     x25, x23, #1          // i
g_i:
    cmp     x25, x20
    bge     g_sigk

    // factor = C[i][k]
    mul     x6, x25, x21
    add     x6, x6, x23
    lsl     x6, x6, #3
    ldr     x26, [x22, x6]        // x26 = C[i][k]

    // si C[i][k] = 0, salta
    cmp     x26, #0
    beq     g_sigi

    // para cada j = 0 .. cols-1:
    //   C[i][j] = C[i][j] * pivote - C[i][k] * C[k][j]
    mov     x27, #0               // j
g_j:
    cmp     x27, x21
    bge     g_sigi

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

    // C[i][j] = C[i][j]*pivote - C[i][k]*C[k][j]
    mul     x9, x9, x24
    mul     x10, x10, x26
    sub     x9, x9, x10
    str     x9, [x22, x6]

    add     x27, x27, #1
    b       g_j

g_sigi:
    add     x25, x25, #1
    b       g_i

g_sigk:
    add     x23, x23, #1
    b       g_k

g_imp:
    // muestra resultado
    ldr     x1, =msg_gauss
    mov     x2, #msg_gauss_len
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