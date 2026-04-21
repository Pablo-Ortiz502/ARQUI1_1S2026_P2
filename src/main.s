.data
msg_filas:        .ascii  "Ingrese numero de filas: "
msg_filas_len   = . - msg_filas

msg_cols:         .ascii  "Ingrese numero de columnas: "
msg_cols_len    = . - msg_cols

msg_err_dim:      .ascii  "Error: dimensiones deben ser mayores a 0\n"
msg_err_dim_len = . - msg_err_dim

msg_a:            .ascii  "a["
msg_a_len       = . - msg_a

msg_coma:         .ascii  "]["
msg_coma_len    = . - msg_coma

msg_igual:        .ascii  "] = "
msg_igual_len   = . - msg_igual

msg_matriz:       .ascii  "\nMatriz ingresada:\n"
msg_matriz_len  = . - msg_matriz

msg_sp:           .ascii  "  "
msg_sp_len      = . - msg_sp

msg_nl:           .ascii  "\n"
msg_nl_len      = . - msg_nl


.bss
.align 3
input_buf:      .skip 32          // buffer entrada
.align 3
out_buf:        .skip 32          // buffer salida
.align 3
filas:          .skip 8
.align 3
columnas:       .skip 8
.align 3
matriz_ptr:     .skip 8           // puntero matriz
.align 3
matriz_size:    .skip 8


.text
.global _start

// main
_start:
    // pide filas
    ldr     x1, =msg_filas
    mov     x2, #msg_filas_len
    bl      print
    bl      leer_entero           // x0 = filas
    ldr     x1, =filas
    str     x0, [x1]              // guarda en filas

    // pide columnas
    ldr     x1, =msg_cols
    mov     x2, #msg_cols_len
    bl      print
    bl      leer_entero           // x0 = columnas
    ldr     x1, =columnas
    str     x0, [x1]              // guarda en columnas

    // valida dimensiones > 0
    ldr     x1, =filas
    ldr     x3, [x1]
    cmp     x3, #0
    ble     error_dim
    ldr     x1, =columnas
    ldr     x4, [x1]
    cmp     x4, #0
    ble     error_dim

    // size = filas * cols * 8
    mul     x5, x3, x4
    lsl     x5, x5, #3
    ldr     x1, =matriz_size
    str     x5, [x1]              // guarda en matriz_size

    // reserva memoria con mmap
    mov     x0, #0
    mov     x1, x5
    mov     x2, #0x3              // PROT_READ | PROT_WRITE
    mov     x3, #0x22             // MAP_PRIVATE | MAP_ANON
    mov     x4, #-1
    mov     x5, #0
    mov     x8, #222
    svc     #0                    // x0 = puntero
    ldr     x1, =matriz_ptr
    str     x0, [x1]              // guarda en matriz_ptr

    // llena matriz
    // x19=i, x20=filas, x21=j, x22=cols
    mov     x19, #0
fila_loop:
    ldr     x1, =filas
    ldr     x20, [x1]
    cmp     x19, x20
    bge     fin_ingreso

    mov     x21, #0
col_loop:
    ldr     x1, =columnas
    ldr     x22, [x1]
    cmp     x21, x22
    bge     siguiente_fila

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
    ldr     x1, =matriz_ptr
    ldr     x7, [x1]
    str     x0, [x7, x6]          // guarda en matriz[i][j]

    add     x21, x21, #1
    b       col_loop

siguiente_fila:
    add     x19, x19, #1
    b       fila_loop

fin_ingreso:
    // imprime matriz
    ldr     x1, =msg_matriz
    mov     x2, #msg_matriz_len
    bl      print

    mov     x19, #0
print_fila_loop:
    ldr     x1, =filas
    ldr     x20, [x1]
    cmp     x19, x20
    bge     fin_programa

    mov     x21, #0
print_col_loop:
    ldr     x1, =columnas
    ldr     x22, [x1]
    cmp     x21, x22
    bge     print_siguiente_fila

    mul     x6, x19, x22
    add     x6, x6, x21
    lsl     x6, x6, #3
    ldr     x1, =matriz_ptr
    ldr     x7, [x1]
    ldr     x0, [x7, x6]          // x0 = matriz[i][j]
    bl      print_entero

    ldr     x1, =msg_sp
    mov     x2, #msg_sp_len
    bl      print

    add     x21, x21, #1
    b       print_col_loop

print_siguiente_fila:
    ldr     x1, =msg_nl
    mov     x2, #msg_nl_len
    bl      print
    add     x19, x19, #1
    b       print_fila_loop

// salida
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
    svc     #0                    // x0 = bytes leidos

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
    udiv    x4, x0, x3            // cociente
    msub    x5, x4, x3, x0        // resto
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