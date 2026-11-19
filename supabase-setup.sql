-- Hidden Gems · tabla de emprendimientos registrados
-- Pégalo completo en Supabase → SQL Editor → New query → Run.

create table if not exists public.emprendimientos (
  id              bigint generated always as identity primary key,
  created_at      timestamptz not null default now(),
  user_id         uuid not null default auth.uid() references auth.users (id) on delete cascade,
  nombre          text not null check (char_length(nombre) between 2 and 80),
  zona            text not null check (zona in ('Zona CityU', 'Centro de Bogotá', 'Otra universidad aledaña')),
  plan            text not null check (plan in ('semilla', 'pro', 'elite')),
  representante   text not null check (char_length(representante) between 3 and 80),
  documento       text not null check (documento ~ '^[0-9]{6,10}$'),
  telefono        text not null check (telefono ~ '^3[0-9]{9}$'),
  correo          text not null check (correo ~* '^[^@\s]+@[^@\s]+\.[a-z]{2,}$'),
  acepta_terminos boolean not null check (acepta_terminos),
  unique (documento, nombre)
);

-- Solo se puede insertar con un correo ya verificado por código, y solo a nombre de ese correo.
-- Nadie puede leer, editar ni borrar desde la página: los registros se ven en el panel de Supabase.
alter table public.emprendimientos enable row level security;

drop policy if exists "registro con correo verificado" on public.emprendimientos;
create policy "registro con correo verificado"
  on public.emprendimientos for insert
  to authenticated
  with check (
    user_id = auth.uid()
    and lower(correo) = lower(auth.jwt() ->> 'email')
  );

grant insert on public.emprendimientos to authenticated;
