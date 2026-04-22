.data
msg_a:            .ascii  "a["
msg_a_len       = . - msg_a

msg_coma:         .ascii  "]["
msg_coma_len    = . - msg_coma

msg_igual:        .ascii  "] = "
msg_igual_len   = . - msg_igual

msg_sp:           .ascii  "  "
msg_sp_len      = . - msg_sp

msg_nl:           .ascii  "\n"
msg_nl_len      = . - msg_nl

msg_err_cuad:     .ascii  "Error: la matriz debe ser cuadrada\n"
msg_err_cuad_len = . - msg_err_cuad

msg_orig:         .ascii  "\nMatriz original:\n"
msg_orig_len    = . - msg_orig

msg_ident:        .ascii  "\nMatriz identidad:\n"
msg_ident_len   = . - msg_ident

msg_trans:        .ascii  "\nMatriz transpuesta:\n"
msg_trans_len   = . - msg_trans


.text
.global ingresar_matriz
.global imprimir_matriz
.global reservar_matriz
.global liberar_matriz
.global matriz_identidad
.global matriz_transpuesta

.extern print
.extern leer_entero
.extern print_entero


// reserva memoria
// x0 = filas, x1 = cols
// retorna x0 = puntero
reservar_matriz:
    stp     x29, x30, [sp, #-16]!

    mul     x2, x0, x1            // total celdas
    lsl     x2, x2, #3            // * 8 bytes

    mov     x0, #0
    mov     x1, x2
    mov     x2, #0x3              // PROT_READ | PROT_WRITE
    mov     x3, #0x22             // MAP_PRIVATE | MAP_ANON
    mov     x4, #-1
    mov     x5, #0
    mov     x8, #222
    svc     #0                    // x0 = puntero

    ldp     x29, x30, [sp], #16
    ret


// libera memoria
// x0 = puntero, x1 = filas, x2 = cols
liberar_matriz:
    stp     x29, x30, [sp, #-16]!

    mul     x1, x1, x2
    lsl     x1, x1, #3            // size = filas*cols*8
    mov     x8, #215              // munmap
    svc     #0

    ldp     x29, x30, [sp], #16
    ret


// pide valores y los guarda
// x0 = puntero, x1 = filas, x2 = cols
ingresar_matriz:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    mov     x23, x0               // puntero
    mov     x20, x1               // filas
    mov     x22, x2               // cols

    mov     x19, #0               // i
ing_fila:
    cmp     x19, x20
    bge     ing_fin

    mov     x21, #0               // j
ing_col:
    cmp     x21, x22
    bge     ing_sig

    // imprime "a[i][j] = "
    ldr     x1, =msg_a
    mov     x2, #msg_a_len
    bl      print
    mov     x0, x19
    bl      print_entero
    ldr     x1, =msg_coma
    mov     x2, #msg_coma_len
    bl      print
    mov     x0, x21
    bl      print_entero
    ldr     x1, =msg_igual
    mov     x2, #msg_igual_len
    bl      print

    bl      leer_entero           // x0 = valor

    // offset = (i*cols + j) * 8
    mul     x6, x19, x22
    add     x6, x6, x21
    lsl     x6, x6, #3
    str     x0, [x23, x6]         // guarda en matriz[i][j]

    add     x21, x21, #1
    b       ing_col
ing_sig:
    add     x19, x19, #1
    b       ing_fila
ing_fin:
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret


// imprime matriz
// x0 = puntero, x1 = filas, x2 = cols
imprimir_matriz:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    mov     x23, x0
    mov     x20, x1
    mov     x22, x2

    mov     x19, #0
imp_fila:
    cmp     x19, x20
    bge     imp_fin

    mov     x21, #0
imp_col:
    cmp     x21, x22
    bge     imp_sig

    mul     x6, x19, x22
    add     x6, x6, x21
    lsl     x6, x6, #3
    ldr     x0, [x23, x6]         // x0 = matriz[i][j]
    bl      print_entero

    ldr     x1, =msg_sp
    mov     x2, #msg_sp_len
    bl      print

    add     x21, x21, #1
    b       imp_col
imp_sig:
    ldr     x1, =msg_nl
    mov     x2, #msg_nl_len
    bl      print
    add     x19, x19, #1
    b       imp_fila
imp_fin:
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret


// genera identidad sin tocar original
// x0 = puntero A, x1 = filas, x2 = cols
matriz_identidad:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    // valida cuadrada
    cmp     x1, x2
    bne     id_error

    mov     x23, x0               // A
    mov     x20, x1               // n

    // muestra original
    ldr     x1, =msg_orig
    mov     x2, #msg_orig_len
    bl      print
    mov     x0, x23
    mov     x1, x20
    mov     x2, x20
    bl      imprimir_matriz

    // reserva B de nxn
    mov     x0, x20
    mov     x1, x20
    bl      reservar_matriz
    mov     x24, x0               // B

    // llena B: 1 en diagonal, 0 fuera
    mov     x19, #0
id_fila:
    cmp     x19, x20
    bge     id_fin

    mov     x21, #0
id_col:
    cmp     x21, x20
    bge     id_sig

    mul     x6, x19, x20
    add     x6, x6, x21
    lsl     x6, x6, #3

    cmp     x19, x21              // i == j ?
    beq     id_uno
    mov     x0, #0
    b       id_guardar
id_uno:
    mov     x0, #1
id_guardar:
    str     x0, [x24, x6]

    add     x21, x21, #1
    b       id_col
id_sig:
    add     x19, x19, #1
    b       id_fila
id_fin:
    // muestra identidad
    ldr     x1, =msg_ident
    mov     x2, #msg_ident_len
    bl      print
    mov     x0, x24
    mov     x1, x20
    mov     x2, x20
    bl      imprimir_matriz

    // libera B
    mov     x0, x24
    mov     x1, x20
    mov     x2, x20
    bl      liberar_matriz
    b       id_ret

id_error:
    ldr     x1, =msg_err_cuad
    mov     x2, #msg_err_cuad_len
    bl      print

id_ret:
    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret


// calcula transpuesta sin tocar original
// x0 = puntero A, x1 = filas, x2 = cols
matriz_transpuesta:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!

    mov     x23, x0               // A
    mov     x20, x1               // filas
    mov     x22, x2               // cols

    // muestra original
    ldr     x1, =msg_orig
    mov     x2, #msg_orig_len
    bl      print
    mov     x0, x23
    mov     x1, x20
    mov     x2, x22
    bl      imprimir_matriz

    // reserva B de cols x filas
    mov     x0, x22
    mov     x1, x20
    bl      reservar_matriz
    mov     x24, x0               // B

    // B[j][i] = A[i][j]
    mov     x19, #0
tr_fila:
    cmp     x19, x20
    bge     tr_fin

    mov     x21, #0
tr_col:
    cmp     x21, x22
    bge     tr_sig

    // offset A = (i*cols + j) * 8
    mul     x6, x19, x22
    add     x6, x6, x21
    lsl     x6, x6, #3
    ldr     x7, [x23, x6]         // A[i][j]

    // offset B = (j*filas + i) * 8
    mul     x8, x21, x20
    add     x8, x8, x19
    lsl     x8, x8, #3
    str     x7, [x24, x8]

    add     x21, x21, #1
    b       tr_col
tr_sig:
    add     x19, x19, #1
    b       tr_fila
tr_fin:
    // muestra transpuesta (cols x filas)
    ldr     x1, =msg_trans
    mov     x2, #msg_trans_len
    bl      print
    mov     x0, x24
    mov     x1, x22
    mov     x2, x20
    bl      imprimir_matriz

    // libera B
    mov     x0, x24
    mov     x1, x22
    mov     x2, x20
    bl      liberar_matriz

    ldp     x23, x24, [sp], #16
    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret