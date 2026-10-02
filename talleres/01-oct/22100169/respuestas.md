# Taller · quitar la mutación

**Nombre:** Rodrigo Alexis Blanco Ceja
**Número de control:** 22100169
**Equipo:** e07

| # | Función | ¿Qué muta la versión de TypeScript? | ¿Quién más se entera del cambio? |
|---|---|---|---|
| 1 | `total_pesos` | El total (acumulador) | El entorno local (Local) |
| 2 | `marcar_urgentes` | Los objetos prestados (embarques) | Quién los tenga |
| 3 | `aplicar_descuento` | Precios (arreglo) | Quien lo mandó |
| 4 | `contar_por_tipo` | Conteo (contador local que se comporta como objeto) | Nadie porque es local |
| 5 | `sin_duplicados` | Set y el arreglo | Nadie |

### ¿Cuál de las cinco era la más peligrosa en TypeScript, y por qué? (dos líneas)

La función **`marcar_urgentes`** (o la 2) era la más peligrosa porque muta directamente la propiedad `urgente` de las referencias de los objetos `Embarque` que le pasaron por parámetro. Al modificar objetos compartidos por referencia, genera efectos secundarios no deseados en cualquier otra parte del sistema que los esté consumiendo.
