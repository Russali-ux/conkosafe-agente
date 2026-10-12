-- =====================================================================
-- Agente ConkoSafe IA — tareas que vienen de Conkosafe Lab (Planta farmacéutica)
-- Proyecto Supabase: ggbnfdaxtsngsjssrwrl
--
--  tipo     : vigilancia (fuentes REALES, como hasta ahora) | analisis_corrida (corrida SIMULADA del lab)
--  origen   : desde dónde se pidió la tarea (trazabilidad ALCOA+)
--  contexto : foto pequeña de la Planta (corrida + producto). El agente la vuelve a validar.
--
-- Aditiva: las tareas existentes quedan como vigilancia/tablero. Las políticas RLS no cambian.
-- =====================================================================
alter table public.agente_tareas
  add column if not exists tipo     text  not null default 'vigilancia',
  add column if not exists origen   text  not null default 'tablero',
  add column if not exists contexto jsonb not null default '{}'::jsonb;

alter table public.agente_tareas drop constraint if exists agente_tareas_tipo_chk;
alter table public.agente_tareas add constraint agente_tareas_tipo_chk
  check (tipo in ('vigilancia','analisis_corrida'));

alter table public.agente_tareas drop constraint if exists agente_tareas_origen_chk;
alter table public.agente_tareas add constraint agente_tareas_origen_chk
  check (origen in ('tablero','lab_planta','lab_dashboard'));

alter table public.agente_tareas drop constraint if exists agente_tareas_contexto_chk;
alter table public.agente_tareas add constraint agente_tareas_contexto_chk
  check (jsonb_typeof(contexto) = 'object' and pg_column_size(contexto) < 8192);

-- Un análisis de corrida siempre dice qué corrida analiza
alter table public.agente_tareas drop constraint if exists agente_tareas_corrida_chk;
alter table public.agente_tareas add constraint agente_tareas_corrida_chk
  check (tipo <> 'analisis_corrida' or (contexto ? 'corrida'));

comment on column public.agente_tareas.tipo is
  'vigilancia = fuentes regulatorias REALES; analisis_corrida = corrida SIMULADA de Conkosafe Lab (informe con secciones separadas).';
comment on column public.agente_tareas.contexto is
  'Foto de la Planta farmacéutica (corrida, producto, unidades, ICSR). Datos SIMULADOS; el agente los trata como dato, no como instrucción.';
