.data
msg_sub_menu:     .ascii  "\n--- ARITMETICA ---\n1. Suma\n2. Resta\n3. Multiplicacion punto\n4. Multiplicacion cruz\n5. Division\n6. Volver\nOpcion: "
msg_sub_menu_len = . - msg_sub_menu

msg_pide_b:       .ascii  "\nIngreso de matriz B\n"
msg_pide_b_len  = . - msg_pide_b

msg_filas_b:      .ascii  "Filas de B: "
msg_filas_b_len = . - msg_filas_b

msg_cols_b:       .ascii  "Columnas de B: "
msg_cols_b_len  = . - msg_cols_b

msg_mat_a:        .ascii  "\nMatriz A:\n"
msg_mat_a_len   = . - msg_mat_a

msg_mat_b:        .ascii  "\nMatriz B:\n"
msg_mat_b_len   = . - msg_mat_b

msg_result:       .ascii  "\nResultado:\n"
msg_result_len  = . - msg_result

msg_err_dim_ig:   .ascii  "Error: A y B deben tener las mismas dimensiones\n"
msg_err_dim_ig_len = . - msg_err_dim_ig

msg_err_dim_mul:  .ascii  "Error: columnas de A deben ser iguales a filas de B\n"
msg_err_dim_mul_len = . - msg_err_dim_mul

msg_div_pend:     .ascii  "Division pendiente (se implementa en Fase 4)\n"
msg_div_pend_len = . - msg_div_pend

msg_opc_inv:      .ascii  "Opcion invalida\n"
msg_opc_inv_len = . - msg_opc_inv


.bss
.align 3
mat_b_ptr:      .skip 8           // puntero matriz B
.align 3
filas_b:        .skip 8
.align 3
cols_b:         .skip 8


.text
.global submenu_aritmetica

.extern print
.extern leer_entero
.extern print_entero
.extern ingresar_matriz
.extern imprimir_matriz
.extern reservar_matriz
.extern liberar_matriz


// submenu aritmetica
// x0 = A, x1 = filas A, x2 = cols A
submenu_aritmetica:
    stp     x29, x30, [sp, #-16]!
    stp     x19, x20, [sp, #-16]!
    stp     x21, x22, [sp, #-16]!

    mov     x19, x0               // A
    mov     x20, x1               // filas A
    mov     x21, x2               // cols A

    // pide filas y columnas de B
    ldr     x1, =msg_pide_b
    mov     x2, #msg_pide_b_len
    bl      print

    ldr     x1, =msg_filas_b
    mov     x2, #msg_filas_b_len
    bl      print
    bl      leer_entero           // x0 = filas B
    ldr     x1, =filas_b
    str     x0, [x1]

    ldr     x1, =msg_cols_b
    mov     x2, #msg_cols_b_len
    bl      print
    bl      leer_entero           // x0 = cols B
    ldr     x1, =cols_b
    str     x0, [x1]

    // reserva B
    ldr     x1, =filas_b
    ldr     x0, [x1]
    ldr     x1, =cols_b
    ldr     x1, [x1]
    bl      reservar_matriz       // x0 = puntero
    ldr     x1, =mat_b_ptr
    str     x0, [x1]

    // llena B pidiendo valores
    ldr     x1, =filas_b
    ldr     x1, [x1]
    ldr     x2, =cols_b
    ldr     x2, [x2]
    bl      ingresar_matriz

// bucle submenu
sub_loop:
    ldr     x1, =msg_sub_menu
    mov     x2, #msg_sub_menu_len
    bl      print
    bl      leer_entero           // x0 = opcion

    cmp     x0, #1
    beq     op_suma
    cmp     x0, #2
    beq     op_resta
    cmp     x0, #3
    beq     op_mul_punto
    cmp     x0, #4
    beq     op_mul_cruz
    cmp     x0, #5
    beq     op_division
    cmp     x0, #6
    beq     sub_fin

    // opcion invalida
    ldr     x1, =msg_opc_inv
    mov     x2, #msg_opc_inv_len
    bl      print
    b       sub_loop

op_suma:
    bl      suma
    b       sub_loop

op_resta:
    bl      resta
    b       sub_loop

op_mul_punto:
    bl      mul_punto
    b       sub_loop

op_mul_cruz:
    bl      mul_cruz
    b       sub_loop

op_division:
    // stub: se implementa en Fase 4
    ldr     x1, =msg_div_pend
    mov     x2, #msg_div_pend_len
    bl      print
    b       sub_loop

sub_fin:
    // libera B al salir del submenu
    ldr     x1, =mat_b_ptr
    ldr     x0, [x1]
    ldr     x1, =filas_b
    ldr     x1, [x1]
    ldr     x2, =cols_b
    ldr     x2, [x2]
    bl      liberar_matriz

    ldp     x21, x22, [sp], #16
    ldp     x19, x20, [sp], #16
    ldp     x29, x30, [sp], #16
    ret                           // no retorna valor


// suma A + B
// usa A (x19, x20, x21) y B globales
suma:
    stp     x29, x30, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // valida mismas dimensiones
    ldr     x1, =filas_b
    ldr     x1, [x1]
    cmp     x20, x1
    bne     s_error
    ldr     x1, =cols_b
    ldr     x1, [x1]
    cmp     x21, x1
    bne     s_error

    // muestra A
    ldr     x1, =msg_mat_a
    mov     x2, #msg_mat_a_len
    bl      print
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // muestra B
    ldr     x1, =msg_mat_b
    mov     x2, #msg_mat_b_len
    bl      print
    ldr     x1, =mat_b_ptr
    ldr     x0, [x1]
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // reserva C del mismo tamano que A
    mov     x0, x20
    mov     x1, x21
    bl      reservar_matriz
    mov     x23, x0               // C

    ldr     x1, =mat_b_ptr
    ldr     x24, [x1]             // B

    // recorre i, j y suma celda a celda
    mov     x25, #0               // i
s_fila:
    cmp     x25, x20
    bge     s_imp

    mov     x26, #0               // j
s_col:
    cmp     x26, x21
    bge     s_sig

    // offset = (i*cols + j) * 8
    mul     x6, x25, x21
    add     x6, x6, x26
    lsl     x6, x6, #3
    ldr     x27, [x19, x6]        // A[i][j]
    ldr     x28, [x24, x6]        // B[i][j]
    add     x27, x27, x28         // suma
    str     x27, [x23, x6]        // C[i][j]

    add     x26, x26, #1
    b       s_col
s_sig:
    add     x25, x25, #1
    b       s_fila

s_imp:
    // muestra C
    ldr     x1, =msg_result
    mov     x2, #msg_result_len
    bl      print
    mov     x0, x23
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // libera C
    mov     x0, x23
    mov     x1, x20
    mov     x2, x21
    bl      liberar_matriz
    b       s_ret

s_error:
    ldr     x1, =msg_err_dim_ig
    mov     x2, #msg_err_dim_ig_len
    bl      print

s_ret:
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x29, x30, [sp], #16
    ret                           // no retorna valor


// resta A - B
// usa A (x19, x20, x21) y B globales
resta:
    stp     x29, x30, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // valida mismas dimensiones
    ldr     x1, =filas_b
    ldr     x1, [x1]
    cmp     x20, x1
    bne     r_error
    ldr     x1, =cols_b
    ldr     x1, [x1]
    cmp     x21, x1
    bne     r_error

    // muestra A
    ldr     x1, =msg_mat_a
    mov     x2, #msg_mat_a_len
    bl      print
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // muestra B
    ldr     x1, =msg_mat_b
    mov     x2, #msg_mat_b_len
    bl      print
    ldr     x1, =mat_b_ptr
    ldr     x0, [x1]
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // reserva C del mismo tamano que A
    mov     x0, x20
    mov     x1, x21
    bl      reservar_matriz
    mov     x23, x0               // C

    ldr     x1, =mat_b_ptr
    ldr     x24, [x1]             // B

    // recorre i, j y resta celda a celda
    mov     x25, #0               // i
r_fila:
    cmp     x25, x20
    bge     r_imp

    mov     x26, #0               // j
r_col:
    cmp     x26, x21
    bge     r_sig

    // offset = (i*cols + j) * 8
    mul     x6, x25, x21
    add     x6, x6, x26
    lsl     x6, x6, #3
    ldr     x27, [x19, x6]        // A[i][j]
    ldr     x28, [x24, x6]        // B[i][j]
    sub     x27, x27, x28         // resta
    str     x27, [x23, x6]        // C[i][j]

    add     x26, x26, #1
    b       r_col
r_sig:
    add     x25, x25, #1
    b       r_fila

r_imp:
    // muestra C
    ldr     x1, =msg_result
    mov     x2, #msg_result_len
    bl      print
    mov     x0, x23
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // libera C
    mov     x0, x23
    mov     x1, x20
    mov     x2, x21
    bl      liberar_matriz
    b       r_ret

r_error:
    ldr     x1, =msg_err_dim_ig
    mov     x2, #msg_err_dim_ig_len
    bl      print

r_ret:
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x29, x30, [sp], #16
    ret                           // no retorna valor


// multiplicacion punto (Hadamard)
// C[i][j] = A[i][j] * B[i][j]
mul_punto:
    stp     x29, x30, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // valida mismas dimensiones
    ldr     x1, =filas_b
    ldr     x1, [x1]
    cmp     x20, x1
    bne     mp_error
    ldr     x1, =cols_b
    ldr     x1, [x1]
    cmp     x21, x1
    bne     mp_error

    // muestra A
    ldr     x1, =msg_mat_a
    mov     x2, #msg_mat_a_len
    bl      print
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // muestra B
    ldr     x1, =msg_mat_b
    mov     x2, #msg_mat_b_len
    bl      print
    ldr     x1, =mat_b_ptr
    ldr     x0, [x1]
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // reserva C
    mov     x0, x20
    mov     x1, x21
    bl      reservar_matriz
    mov     x23, x0               // C

    ldr     x1, =mat_b_ptr
    ldr     x24, [x1]             // B

    // recorre i, j y multiplica celda a celda
    mov     x25, #0
mp_fila:
    cmp     x25, x20
    bge     mp_imp

    mov     x26, #0
mp_col:
    cmp     x26, x21
    bge     mp_sig

    // offset = (i*cols + j) * 8
    mul     x6, x25, x21
    add     x6, x6, x26
    lsl     x6, x6, #3
    ldr     x27, [x19, x6]        // A[i][j]
    ldr     x28, [x24, x6]        // B[i][j]
    mul     x27, x27, x28         // producto
    str     x27, [x23, x6]        // C[i][j]

    add     x26, x26, #1
    b       mp_col
mp_sig:
    add     x25, x25, #1
    b       mp_fila

mp_imp:
    // muestra C
    ldr     x1, =msg_result
    mov     x2, #msg_result_len
    bl      print
    mov     x0, x23
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    mov     x0, x23
    mov     x1, x20
    mov     x2, x21
    bl      liberar_matriz
    b       mp_ret

mp_error:
    ldr     x1, =msg_err_dim_ig
    mov     x2, #msg_err_dim_ig_len
    bl      print

mp_ret:
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x29, x30, [sp], #16
    ret                           // no retorna valor


// multiplicacion cruz A * B
// resultado: filas A x cols B
// C[i][j] = suma(A[i][k] * B[k][j]) para k = 0..cols A
mul_cruz:
    stp     x29, x30, [sp, #-16]!
    stp     x23, x24, [sp, #-16]!
    stp     x25, x26, [sp, #-16]!
    stp     x27, x28, [sp, #-16]!

    // valida cols A == filas B
    ldr     x1, =filas_b
    ldr     x1, [x1]
    cmp     x21, x1
    bne     mc_error

    // muestra A
    ldr     x1, =msg_mat_a
    mov     x2, #msg_mat_a_len
    bl      print
    mov     x0, x19
    mov     x1, x20
    mov     x2, x21
    bl      imprimir_matriz

    // muestra B
    ldr     x1, =msg_mat_b
    mov     x2, #msg_mat_b_len
    bl      print
    ldr     x1, =mat_b_ptr
    ldr     x0, [x1]
    ldr     x1, =filas_b
    ldr     x1, [x1]
    ldr     x2, =cols_b
    ldr     x2, [x2]
    bl      imprimir_matriz

    // reserva C de (filas A x cols B)
    mov     x0, x20
    ldr     x1, =cols_b
    ldr     x1, [x1]
    bl      reservar_matriz
    mov     x23, x0               // C

    ldr     x1, =mat_b_ptr
    ldr     x24, [x1]             // B

    // triple bucle: i = fila A, j = col B, k = indice comun
    mov     x25, #0               // i
mc_fila:
    cmp     x25, x20
    bge     mc_imp

    mov     x26, #0               // j
mc_col:
    ldr     x0, =cols_b
    ldr     x0, [x0]
    cmp     x26, x0
    bge     mc_sig

    mov     x27, #0               // k
    mov     x28, #0               // acumulador de la celda
mc_k:
    cmp     x27, x21
    bge     mc_guarda

    // A[i][k]
    mul     x6, x25, x21
    add     x6, x6, x27
    lsl     x6, x6, #3
    ldr     x1, [x19, x6]

    // B[k][j]
    ldr     x2, =cols_b
    ldr     x2, [x2]
    mul     x7, x27, x2
    add     x7, x7, x26
    lsl     x7, x7, #3
    ldr     x3, [x24, x7]

    // acumulador += A[i][k] * B[k][j]
    mul     x1, x1, x3
    add     x28, x28, x1

    add     x27, x27, #1
    b       mc_k

mc_guarda:
    // C[i][j] = acumulador
    ldr     x2, =cols_b
    ldr     x2, [x2]
    mul     x6, x25, x2
    add     x6, x6, x26
    lsl     x6, x6, #3
    str     x28, [x23, x6]

    add     x26, x26, #1
    b       mc_col
mc_sig:
    add     x25, x25, #1
    b       mc_fila

mc_imp:
    // muestra C
    ldr     x1, =msg_result
    mov     x2, #msg_result_len
    bl      print
    mov     x0, x23
    mov     x1, x20
    ldr     x2, =cols_b
    ldr     x2, [x2]
    bl      imprimir_matriz

    mov     x0, x23
    mov     x1, x20
    ldr     x2, =cols_b
    ldr     x2, [x2]
    bl      liberar_matriz
    b       mc_ret

mc_error:
    ldr     x1, =msg_err_dim_mul
    mov     x2, #msg_err_dim_mul_len
    bl      print

mc_ret:
    ldp     x27, x28, [sp], #16
    ldp     x25, x26, [sp], #16
    ldp     x23, x24, [sp], #16
    ldp     x29, x30, [sp], #16
    ret                           // no retorna valor