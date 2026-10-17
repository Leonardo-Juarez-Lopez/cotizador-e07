# Taller 3 · La mutación escondida
**Estudiante:** Rodrigo Alexis Blanco Ceja  
**Número de Control:** 22100169  

---

## Tabla de Predicción vs Ejecución (TypeScript)

| Función | Predigo | Salió |
| :--- | :--- | :--- |
| **1. ordenarPorPeso** | `B,A true` | `B,A true` |
| **2. conDescuento** | `10 true` | `10 true` |
| **3. registrar** | `2 true` | `2 true` |
| **4. conPermiso** | `SCT-77 false` | `SCT-77 false` |
| **5. fechaDeEntrega** | `15 15` | `15 15` |

---

## Análisis de Mutación (TypeScript)

### 1. `ordenarPorPeso`
* **Línea que muta:** `embarques.sort(...)` reordena los elementos directamente en el arreglo original (*in-place*).
* **Quién más se entera:** Cualquier otra parte del programa o pantalla que conserve una referencia al arreglo `lote`.

### 2. `conDescuento`
* **Línea que muta:** `reglas.descuentoPct = pct` escribe directamente en el objeto recibido.
* **Quién más se entera:** Todos los procesos que compartan la referencia al objeto `base` de reglas generales.

### 3. `registrar`
* **Línea que muta:** `vistos.push(id)` modifica el arreglo compartido que vive fuera de la función.
* **Quién más se entera:** Cualquier llamada previa o futura a la función, ya que no es una función pura y genera efectos secundarios en la variable global/compartida.

### 4. `conPermiso`
* **Línea que muta:** `copia.documentos.permiso = permiso` modifica el objeto anidado `documentos`.
* **Quién más se entera:** El objeto `original`, debido a que el operador *spread* `{ ...e }` realiza una copia superficial (*shallow copy*) y el segundo nivel apunta a la misma dirección de memoria.

### 5. `fechaDeEntrega`
* **Línea que muta:** `salida.setDate(...)` altera el estado interno del objeto `Date`.
* **Quién más se entera:** Cualquier variable que tuviera guardada la fecha original de salida.

---

## Elixir y la Inmutabilidad

### ¿Por qué las pruebas en Elixir garantizan que el dato original no cambia?
En Elixir **todos los tipos de datos son estrictamente inmutables**. No existe la mutación en memoria ni la modificación *in-place*. Cuando una función en Elixir opera sobre una estructura (lista, mapa, fecha), siempre genera y retorna una **estructura completamente nueva en memoria**, asegurando que las referencias y variables originales se mantengan 100% intactas. Por esta razón, las aserciones que verifican la integridad del dato original nunca pueden fallar en Elixir.