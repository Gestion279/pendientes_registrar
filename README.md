# Pendientes bancarios

App para cargar los Excel de pendientes de Darío, tildar cada movimiento cuando se registra y dejar un comentario. Varios operadores trabajan a la vez y ven los cambios en vivo.

Es un sitio estático (HTML + JavaScript), sin paso de compilación. Los datos se guardan en Supabase (proyecto `zewgswnatkthgzqahdeq`, tablas `pend_movimientos` y `pend_operadores`).

## Publicar

1. Crear un repositorio nuevo en GitHub y subir el contenido de esta carpeta (`index.html`, `config.js`, `vercel.json`, `README.md`, `supabase/`).
2. En Vercel: **Add New → Project**, importar el repositorio. Framework Preset: **Other**. No hace falta configurar build ni variables de entorno. **Deploy**.
3. Cada `git push` a la rama principal vuelve a publicar automáticamente.

## Dar acceso a un operador

Hacen falta dos pasos en el panel de Supabase:

1. **Authentication → Users → Add user → Create new user**: email y contraseña, con *Auto Confirm User* marcado.
2. **SQL Editor**, ejecutar:

```sql
insert into public.pend_operadores (email, nombre)
values ('operador@empresa.com', 'Nombre que se muestra');
```

Para quitar el acceso: `delete from public.pend_operadores where email = 'operador@empresa.com';`

Solo los emails de esa lista pueden ver o modificar movimientos, aunque alguien cree una cuenta por su cuenta.

Para cambiar una contraseña: **Authentication → Users**, menú de la fila → *Reset password* o editar el usuario.

## Cómo identifica duplicados

Cada fila se identifica por fecha + proveedor (normalizado) + monto, más un número de orden cuando hay filas iguales en el mismo archivo. Volver a subir un archivo no duplica nada. Si una carga trae una fila igual de más, entra marcada como posible duplicado para que un operador la confirme o la quite.

Las filas de un mes que ya no vienen en el Excel nuevo de ese mes pasan a “Darío ya no las tiene pendientes”. Por eso cada Excel tiene que traer la lista completa del mes.
