.data
// --- Mensajes al usuario ---
msg_filas:        .ascii  "Ingrese numero de filas: "
msg_filas_len   = . - msg_filas

msg_cols:         .ascii  "Ingrese numero de columnas: "
msg_cols_len    = . - msg_cols

msg_result:       .ascii  "\nDimensiones recibidas: "
msg_result_len  = . - msg_result

msg_x:            .ascii  " x "
msg_x_len       = . - msg_x

msg_nl:           .ascii  "\n"
msg_nl_len      = . - msg_nl


.bss
// --- Buffers y variables globales ---
.align 3
input_buf:      .skip 32     // buffer para leer de stdin
.align 3
out_buf:        .skip 32     // buffer para convertir int -> string
.align 3
filas:          .skip 8      // entero: numero de filas
.align 3
columnas:       .skip 8      // entero: numero de columnas

.text
.global _start


// _start : punto de entrada

_start:
    // --- Pedir filas ---
    ldr     x1, =msg_filas
    mov     x2, #msg_filas_len
    bl      print

    bl      leer_entero          // retorna valor en x0
    ldr     x1, =filas
    str     x0, [x1]             // filas = valor

    // --- Pedir columnas ---
    ldr     x1, =msg_cols
    mov     x2, #msg_cols_len
    bl      print

    bl      leer_entero
    ldr     x1, =columnas
    str     x0, [x1]

    // --- Confirmar: "Dimensiones recibidas: F x C" ---
    ldr     x1, =msg_result
    mov     x2, #msg_result_len
    bl      print

    ldr     x1, =filas
    ldr     x0, [x1]
    bl      print_entero

    ldr     x1, =msg_x
    mov     x2, #msg_x_len
    bl      print

    ldr     x1, =columnas
    ldr     x0, [x1]
    bl      print_entero

    ldr     x1, =msg_nl
    mov     x2, #msg_nl_len
    bl      print

    // --- Salir ---
    mov     x0, #0
    mov     x8, #93              // syscall exit
    svc     #0


// print : imprime cadena en stdout
// Entradas: x1 = puntero, x2 = longitud
print:
    mov     x0, #1               // fd = stdout
    mov     x8, #64              // syscall write
    svc     #0
    ret



// leer_entero : lee una linea de stdin y la convierte a int64
// Retorno: x0 = valor numerico

leer_entero:
    stp     x29, x30, [sp, #-16]!

    // read(0, input_buf, 32)
    mov     x0, #0               // fd = stdin
    ldr     x1, =input_buf
    mov     x2, #32
    mov     x8, #63              // syscall read
    svc     #0

    mov     x2, x0               // x2 = bytes leidos
    ldr     x1, =input_buf       // x1 = puntero al buffer

    // atoi: acumular digito a digito
    mov     x0, #0               // acumulador
    mov     x3, #0               // indice
    mov     x5, #10
atoi_loop:
    cmp     x3, x2
    bge     atoi_fin
    ldrb    w4, [x1, x3]
    cmp     w4, #'0'
    blt     atoi_fin             // no es digito -> salir
    cmp     w4, #'9'
    bgt     atoi_fin
    sub     w4, w4, #'0'
    mul     x0, x0, x5
    add     x0, x0, x4
    add     x3, x3, #1
    b       atoi_loop
atoi_fin:
    ldp     x29, x30, [sp], #16
    ret



// print_entero : imprime int64 en stdout
// Entrada: x0 = valor

print_entero:
    stp     x29, x30, [sp, #-16]!

    ldr     x1, =out_buf
    add     x1, x1, #31          // apuntar al final del buffer
    mov     x2, #0               // contador de digitos
    mov     x3, #10

    // Caso especial: numero == 0
    cmp     x0, #0
    bne     itoa_loop
    mov     w4, #'0'
    strb    w4, [x1]
    mov     x2, #1
    b       itoa_print

itoa_loop:
    cmp     x0, #0
    beq     itoa_print
    udiv    x4, x0, x3           // x4 = x0 / 10
    msub    x5, x4, x3, x0       // x5 = x0 - x4*10  (resto)
    add     w5, w5, #'0'
    sub     x1, x1, #1
    strb    w5, [x1]
    mov     x0, x4
    add     x2, x2, #1
    b       itoa_loop

itoa_print:
    mov     x0, #1               // stdout
    mov     x8, #64              // write
    svc     #0

    ldp     x29, x30, [sp], #16
    ret
