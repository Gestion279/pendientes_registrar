# Pendientes bancarios

App para cargar los Excel de pendientes de Darío, tildar cada movimiento cuando se registra y dejar un comentario. Varios operadores trabajan a la vez y ven los cambios en vivo.

Es un sitio estático (HTML + JavaScript), sin paso de compilación. Los datos se guardan en Supabase (proyecto `zewgswnatkthgzqahdeq`, tablas `pend_movimientos` y `pend_operadores`).

## Publicar

1. Crear un repositorio nuevo en GitHub y subir el contenido de esta carpeta (`index.html`, `config.js`, `vercel.json`, `README.md`, `supabase/`).
2. En Vercel: **Add New → Project**, importar el repositorio. Framework Preset: **Other**. No hace falta configurar build ni variables de entorno. **Deploy**.
3. Cada `git push` a la rama principal vuelve a publicar automáticamente.

## Acceso

La app es de libre acceso: cualquiera con el enlace puede verla y usarla. Cada operador escribe su nombre arriba, en “Operador”; el navegador lo recuerda y se usa para mostrar quién registró o comentó cada movimiento. La página está marcada para que los buscadores no la indexen.

## Cómo identifica duplicados

Cada fila se identifica por fecha + proveedor (normalizado) + monto, más un número de orden cuando hay filas iguales en el mismo archivo. Volver a subir un archivo no duplica nada. Si una carga trae una fila igual de más, entra marcada como posible duplicado para que un operador la confirme o la quite.

Las filas de un mes que ya no vienen en el Excel nuevo de ese mes pasan a “Darío ya no las tiene pendientes”. Por eso cada Excel tiene que traer la lista completa del mes.
