-- Ya aplicada en el proyecto zewgswnatkthgzqahdeq. Se guarda como referencia.
create table public.pend_operadores (
  email text primary key check (email = lower(email)),
  nombre text not null default '',
  creado_en timestamptz not null default now()
);
alter table public.pend_operadores enable row level security;

create or replace function public.pend_es_operador()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.pend_operadores o
                 where o.email = lower(coalesce(auth.jwt() ->> 'email', '')));
$$;
revoke all on function public.pend_es_operador() from public, anon;
grant execute on function public.pend_es_operador() to authenticated;

create policy "pend_operadores_select" on public.pend_operadores
  for select to authenticated using (public.pend_es_operador());

create table public.pend_movimientos (
  id text primary key, clave text not null, n int not null default 1,
  fecha date not null, mes text not null,
  nombre text not null default '', concepto text not null default '', detalle text not null default '',
  monto numeric(16,2) not null, nota_dario text not null default '',
  en_lista boolean not null default true, quitado_en date, dudosa boolean not null default false,
  registrado boolean not null default false, reg_por text, reg_en timestamptz,
  comentario text not null default '', com_por text, com_en timestamptz,
  archivo text, creado_en timestamptz not null default now(), creado_por text
);
create index pend_movimientos_mes_idx on public.pend_movimientos (mes);
create index pend_movimientos_clave_idx on public.pend_movimientos (clave);
alter table public.pend_movimientos enable row level security;
create policy "pend_mov_select" on public.pend_movimientos for select to authenticated using (public.pend_es_operador());
create policy "pend_mov_insert" on public.pend_movimientos for insert to authenticated with check (public.pend_es_operador());
create policy "pend_mov_update" on public.pend_movimientos for update to authenticated using (public.pend_es_operador()) with check (public.pend_es_operador());
create policy "pend_mov_delete" on public.pend_movimientos for delete to authenticated using (public.pend_es_operador());
revoke all on public.pend_movimientos from anon;
revoke all on public.pend_operadores from anon;
alter publication supabase_realtime add table public.pend_movimientos;

-- 002: acceso libre (sin inicio de sesión)
drop policy if exists "pend_mov_select" on public.pend_movimientos;
drop policy if exists "pend_mov_insert" on public.pend_movimientos;
drop policy if exists "pend_mov_update" on public.pend_movimientos;
drop policy if exists "pend_mov_delete" on public.pend_movimientos;
create policy "pend_mov_libre_select" on public.pend_movimientos for select to anon, authenticated using (true);
create policy "pend_mov_libre_insert" on public.pend_movimientos for insert to anon, authenticated with check (true);
create policy "pend_mov_libre_update" on public.pend_movimientos for update to anon, authenticated using (true) with check (true);
create policy "pend_mov_libre_delete" on public.pend_movimientos for delete to anon, authenticated using (true);
grant select, insert, update, delete on public.pend_movimientos to anon;

-- 003: historial de comentarios
create table public.pend_comentarios (
  id uuid primary key default gen_random_uuid(),
  mov_id text not null references public.pend_movimientos(id) on delete cascade,
  autor text not null check (length(btrim(autor)) > 0),
  texto text not null check (length(btrim(texto)) > 0),
  creado_en timestamptz not null default now()
);
create index pend_comentarios_mov_idx on public.pend_comentarios (mov_id, creado_en);
alter table public.pend_comentarios enable row level security;
create policy "pend_com_libre_select" on public.pend_comentarios for select to anon, authenticated using (true);
create policy "pend_com_libre_insert" on public.pend_comentarios for insert to anon, authenticated with check (true);
create policy "pend_com_libre_delete" on public.pend_comentarios for delete to anon, authenticated using (true);
grant select, insert, delete on public.pend_comentarios to anon;
insert into public.pend_comentarios (mov_id, autor, texto, creado_en)
select id, coalesce(nullif(btrim(com_por), ''), 'Sin nombre'), comentario, coalesce(com_en, now())
from public.pend_movimientos where btrim(comentario) <> '';
alter publication supabase_realtime add table public.pend_comentarios;
