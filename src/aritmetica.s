.data
msg_sub_menu:     .ascii  "\n--- ARITMETICA ---\n1. Suma\n2. Volver\nOpcion: "
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

msg_opc_inv:      .ascii  "Opcion invalida\n"
msg_opc_inv_len = . - msg_opc_inv


.bss
.align 3
mat_b_ptr:      .skip 8
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

    // pide matriz B
    ldr     x1, =msg_pide_b
    mov     x2, #msg_pide_b_len
    bl      print

    ldr     x1, =msg_filas_b
    mov     x2, #msg_filas_b_len
    bl      print
    bl      leer_entero
    ldr     x1, =filas_b
    str     x0, [x1]

    ldr     x1, =msg_cols_b
    mov     x2, #msg_cols_b_len
    bl      print
    bl      leer_entero
    ldr     x1, =cols_b
    str     x0, [x1]

    // reserva B
    ldr     x1, =filas_b
    ldr     x0, [x1]
    ldr     x1, =cols_b
    ldr     x1, [x1]
    bl      reservar_matriz
    ldr     x1, =mat_b_ptr
    str     x0, [x1]

    // llena B
    ldr     x1, =filas_b
    ldr     x1, [x1]
    ldr     x2, =cols_b
    ldr     x2, [x2]
    bl      ingresar_matriz

sub_loop:
    ldr     x1, =msg_sub_menu
    mov     x2, #msg_sub_menu_len
    bl      print
    bl      leer_entero

    cmp     x0, #1
    beq     op_suma
    cmp     x0, #2
    beq     sub_fin

    ldr     x1, =msg_opc_inv
    mov     x2, #msg_opc_inv_len
    bl      print
    b       sub_loop

op_suma:
    bl      suma
    b       sub_loop

sub_fin:
    // libera B
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
    ret


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

    // reserva C
    mov     x0, x20
    mov     x1, x21
    bl      reservar_matriz
    mov     x23, x0               // C

    ldr     x1, =mat_b_ptr
    ldr     x24, [x1]             // B

    // C[i][j] = A[i][j] + B[i][j]
    mov     x25, #0               // i
s_fila:
    cmp     x25, x20
    bge     s_imp

    mov     x26, #0               // j
s_col:
    cmp     x26, x21
    bge     s_sig

    mul     x6, x25, x21
    add     x6, x6, x26
    lsl     x6, x6, #3
    ldr     x27, [x19, x6]        // A[i][j]
    ldr     x28, [x24, x6]        // B[i][j]
    add     x27, x27, x28
    str     x27, [x23, x6]

    add     x26, x26, #1
    b       s_col
s_sig:
    add     x25, x25, #1
    b       s_fila

s_imp:
    // muestra resultado
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
    ret