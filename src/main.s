.data
msg_filas:        .ascii  "Ingrese numero de filas: "
msg_filas_len   = . - msg_filas

msg_cols:         .ascii  "Ingrese numero de columnas: "
msg_cols_len    = . - msg_cols

msg_err_dim:      .ascii  "Error: dimensiones deben ser mayores a 0\n"
msg_err_dim_len = . - msg_err_dim

msg_menu:         .ascii  "\n=== MENU ===\n1. Matriz identidad\n2. Matriz transpuesta\n3. Aritmetica\n4. Metodo de Gauss\n5. Gauss-Jordan\n6. Determinante\n7. Matriz inversa\n8. Salir\nOpcion: "
msg_menu_len    = . - msg_menu

msg_matriz:       .ascii  "\nMatriz ingresada:\n"
msg_matriz_len  = . - msg_matriz

msg_opc_inv:      .ascii  "Opcion invalida\n"
msg_opc_inv_len = . - msg_opc_inv


.bss
.align 3
filas:          .skip 8
.align 3
columnas:       .skip 8
.align 3
matriz_ptr:     .skip 8


.text
.global _start
.extern print
.extern leer_entero
.extern print_entero
.extern ingresar_matriz
.extern imprimir_matriz
.extern reservar_matriz
.extern matriz_identidad
.extern matriz_transpuesta
.extern submenu_aritmetica
.extern metodo_gauss
.extern matriz_inversa 


// main
_start:
    // pide filas
    ldr     x1, =msg_filas
    mov     x2, #msg_filas_len
    bl      print
    bl      leer_entero
    ldr     x1, =filas
    str     x0, [x1]

    // pide columnas
    ldr     x1, =msg_cols
    mov     x2, #msg_cols_len
    bl      print
    bl      leer_entero
    ldr     x1, =columnas
    str     x0, [x1]

    // valida dimensiones > 0
    ldr     x1, =filas
    ldr     x19, [x1]
    cmp     x19, #0
    ble     error_dim
    ldr     x1, =columnas
    ldr     x20, [x1]
    cmp     x20, #0
    ble     error_dim

    // reserva memoria
    mov     x0, x19
    mov     x1, x20
    bl      reservar_matriz
    ldr     x1, =matriz_ptr
    str     x0, [x1]

    // llena matriz
    mov     x1, x19
    mov     x2, x20
    bl      ingresar_matriz

    // muestra lo ingresado
    ldr     x1, =msg_matriz
    mov     x2, #msg_matriz_len
    bl      print
    ldr     x1, =matriz_ptr
    ldr     x0, [x1]
    mov     x1, x19
    mov     x2, x20
    bl      imprimir_matriz

menu_loop:
    ldr     x1, =msg_menu
    mov     x2, #msg_menu_len
    bl      print
    bl      leer_entero

    cmp     x0, #1
    beq     op_identidad
    cmp     x0, #2
    beq     op_transpuesta
    cmp     x0, #3
    beq     op_aritmetica
    cmp     x0, #4
    beq     op_gauss
    cmp     x0, #5
    beq     op_jordan
    cmp     x0, #6
    beq     op_det
    cmp     x0, #7
    beq     op_inversa
    cmp     x0, #8

    beq     fin_programa
    ldr     x1, =msg_opc_inv
    mov     x2, #msg_opc_inv_len
    bl      print
    b       menu_loop

op_identidad:
    ldr     x1, =matriz_ptr
    ldr     x0, [x1]
    ldr     x1, =filas
    ldr     x1, [x1]
    ldr     x2, =columnas
    ldr     x2, [x2]
    bl      matriz_identidad
    b       menu_loop

op_transpuesta:
    ldr     x1, =matriz_ptr
    ldr     x0, [x1]
    ldr     x1, =filas
    ldr     x1, [x1]
    ldr     x2, =columnas
    ldr     x2, [x2]
    bl      matriz_transpuesta
    b       menu_loop

op_gauss:
    ldr     x1, =matriz_ptr
    ldr     x0, [x1]
    ldr     x1, =filas
    ldr     x1, [x1]
    ldr     x2, =columnas
    ldr     x2, [x2]
    bl      metodo_gauss
    b       menu_loop

op_jordan:
    ldr     x1, =matriz_ptr
    ldr     x0, [x1]
    ldr     x1, =filas
    ldr     x1, [x1]
    ldr     x2, =columnas
    ldr     x2, [x2]
    bl      metodo_jordan
    b       menu_loop
op_det:
    ldr     x1, =matriz_ptr
    ldr     x0, [x1]
    ldr     x1, =filas
    ldr     x1, [x1]
    ldr     x2, =columnas
    ldr     x2, [x2]
    bl      determinante
    b       menu_loop

op_inversa:
    ldr     x1, =matriz_ptr
    ldr     x0, [x1]
    ldr     x1, =filas
    ldr     x1, [x1]
    ldr     x2, =columnas
    ldr     x2, [x2]
    bl      matriz_inversa
    b       menu_loop

op_aritmetica:
    ldr     x1, =matriz_ptr
    ldr     x0, [x1]
    ldr     x1, =filas
    ldr     x1, [x1]
    ldr     x2, =columnas
    ldr     x2, [x2]
    bl      submenu_aritmetica
    b       menu_loop

// salida ok
fin_programa:
    mov     x0, #0
    mov     x8, #93
    svc     #0

// error dimensiones
error_dim:
    ldr     x1, =msg_err_dim
    mov     x2, #msg_err_dim_len
    bl      print
    mov     x0, #1
    mov     x8, #93
    svc     #0