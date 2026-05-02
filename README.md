# Manual Técnico

## 1. Requisitos del entorno

| Componente | Versión / Detalle |
|---|---|
| Sistema operativo host | Windows 11 con WSL2 (Ubuntu) |
| Toolchain cruzado | `gcc-aarch64-linux-gnu`, `binutils-aarch64-linux-gnu` |
| Emulador | `qemu-user` |
| Editor | Visual Studio Code (con extensión WSL) |


---


## 2. Compilación y ejecución

### Comandos disponibles

```bash
make          # ensambla y enlaza todo
make run      # ejecuta el binario en QEMU
make debug    # lanza gdbserver en el puerto 1234
make clean    # borra build/
```

### Flujo interno del Makefile

1. Cada `.s` en `src/` se ensambla con `aarch64-linux-gnu-as` produciendo un `.o` en `build/`.
2. Todos los `.o` se enlazan con `aarch64-linux-gnu-ld` para generar `build/motor`.
3. `make run` ejecuta el binario con `qemu-aarch64`.

**[IMAGEN: captura de la salida de `make` exitoso]**

---

## 2. Convenciones

### Registros

| Registro | Uso |
|---|---|
| `x0` | primer parámetro / valor de retorno |
| `x1`, `x2` | parámetros adicionales |
| `x8` | número de syscall |
| `x19`–`x28` | variables locales preservadas entre llamadas (callee-saved) |
| `x29`, `x30` | frame pointer y link register, salvados en stack al entrar a cada rutina |

### Representación de matrices

Las matrices se almacenan como un bloque contiguo de memoria reservado con `mmap`, usando representación **row-major**. La fórmula de acceso es:

```
offset(i, j) = (i * cols + j) * 8
```

Cada celda ocupa 8 bytes (entero con signo de 64 bits).

---

## 3. Módulos y rutinas

### 3.1 `io.s` — Entrada y salida

| Rutina | Parámetros | Retorno | Descripción |
|---|---|---|---|
| `print` | x1 = ptr, x2 = len | — | Escribe una cadena en stdout |
| `leer_entero` | — | x0 = valor | Lee una línea de stdin y la convierte a entero (atoi con signo) |
| `print_entero` | x0 = valor | — | Convierte un entero a texto y lo imprime (itoa con signo) |


### 3.2 `matriz.s` — Operaciones básicas sobre matriz

| Rutina | Descripción |
|---|---|
| `reservar_matriz` | Reserva memoria para una matriz con `mmap` |
| `liberar_matriz` | Libera memoria con `munmap` |
| `ingresar_matriz` | Pide cada celda con formato `a[i][j] = valor` |
| `imprimir_matriz` | Recorre la matriz y la imprime en formato tabular |
| `matriz_identidad` | Genera la identidad sin tocar la matriz original |
| `matriz_transpuesta` | Calcula la transpuesta sin tocar la matriz original |


### 3.3 `aritmetica.s` — Operaciones aritméticas

| Rutina | Validación | Descripción |
|---|---|---|
| `suma` | dim(A) = dim(B) | C[i][j] = A[i][j] + B[i][j] |
| `resta` | dim(A) = dim(B) | C[i][j] = A[i][j] − B[i][j] |
| `mul_punto` | dim(A) = dim(B) | C[i][j] = A[i][j] · B[i][j] |
| `mul_cruz` | cols(A) = filas(B) | A x B |
| `division` | B cuadrada, cols(A)=filas(B), B invertible | A × B⁻¹ |


### 3.4 `gauss.s`, `jordan.s`, `determinante.s`, `inversa.s`

Cada archivo expone una rutina principal homónima. Todas siguen:

```
x0 = puntero a A, x1 = filas, x2 = columnas
```

Y ninguna modifica la matriz original todas trabajan sobre una copia.


---

## 4. Algoritmos implementados

### 4.1 Método de Gauss

Transforma la matriz a forma triangular superior usando una variante "fracciones libres" del algoritmo clásico:

```
Para cada columna pivote k:
  Para cada fila i debajo de k:
    factor = A[i][k]
    Para cada j:
      A[i][j] = A[i][j] · pivote − factor · A[k][j]
```

### 4.2 Gauss-Jordan

Extiende Gauss eliminando también hacia arriba y luego normalizando cada fila por su pivote.


### 4.3 Determinante (algoritmo de Bareiss)

Variante de Gauss.

```
det = ±1 · M[n-1][n-1]
```


### 4.4 Matriz inversa

Construye la matriz aumentada `[A | I]` de tamaño n × 2n, le aplica Gauss-Jordan completo, y al finalizar el bloque derecho contiene `A⁻¹`.


### 4.5 División de matrices

`A / B` se define como `A × B⁻¹`, validando previamente que B sea cuadrada e invertible y que las dimensiones permitan la multiplicación.

---

## 5. Imagenes

### 5.1 Ingreso de matriz

![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20180117.png)

### 5.2 Identidad

![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20183315.png)

### 5.3 Transpuesta

![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20183531.png)

### 5.4 Suma, resta, multiplicación punto y cruz
#### suma
![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20183759.png)

##### resta
![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20184133.png)

#### Multiplicacion punto
![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20184429.png)

#### multiplicacion cruz
![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20184600.png)


### 5.5 Gauss
![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20184703.png)

### 5.6 Gauss-Jordan
![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20184918.png)

### 5.7 Determinante
![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20185007.png)


### 5.8 Inversa
![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20190502.png)

### 5.9 División
![Ingreson de matriz](./imagenes/Screenshot%202026-05-01%20190735.png)

