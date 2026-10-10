# Agente ConkoSafe IA

Agente de vigilancia multifuente. Recibe instrucciones desde una página web, consulta las
fuentes regulatorias ya cargadas en Supabase y entrega un informe. Vive en su propio repo
para no interferir con **Alertas-analyzer**: comparte solo la base de datos.

- Tablero: https://russali-ux.github.io/conkosafe-agente/
- Modelo por defecto: `claude-haiku-5-5` (cambiable con la variable de Actions `AGENTE_MODELO`)

```
index.html ──insert──▶ agente_tareas ──▶ Edge Function agente-despachar
     ▲                                          │ repository_dispatch
     │ tiempo real                              ▼
agente_eventos ◀── cada paso ── agente.py (GitHub Actions de ESTE repo + Claude)
                                   │ solo LEE las tablas de Alertas-analyzer:
                                   │ alertas_digemid, modificatorias_digemid, cima_cambios,
                                   │ pavs_alertas, fda_aems_senales, ema_prac_senales,
                                   │ ema_arbitrajes, alertas_cdsco, pvpi_senales, medicamentos
                                   └ escribe solo en agente_tareas / agente_eventos
```

## Qué comparte con Alertas-analyzer y qué no

| | Alertas-analyzer | conkosafe-agente |
|---|---|---|
| Código y workflows | scrapers, módulos | solo el agente |
| Supabase | escribe las tablas de fuentes | las **lee**; escribe solo `agente_*` |
| Inicio de sesión | formulario de login | reutiliza la misma sesión (mismo dominio `russali-ux.github.io`, clave `sb-alertas-digemid-auth`) |
| Scrapers | los ejecuta | puede dispararlos solo si tiene `ANALYZER_DISPATCH_TOKEN` (opcional) |

## Archivos

| Archivo | Qué es |
|---|---|
| `index.html` | Tablero (GitHub Pages) |
| `agente.py` | El agente: Claude + herramientas sobre Supabase; motor heurístico si Claude falla |
| `.github/workflows/agente.yml` | Ejecuta el agente |
| `supabase/functions/agente-despachar/index.ts` | Edge Function que despierta al agente |
| `supabase/migrations/001_agente.sql` | Tablas `agente_tareas` y `agente_eventos` (ya aplicada) |

## Configuración

**GitHub → Settings → Secrets and variables → Actions** (de este repo):

| Secreto | Obligatorio | Valor |
|---|---|---|
| `SUPABASE_URL` | sí | `https://ggbnfdaxtsngsjssrwrl.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | sí | Supabase → Project Settings → API keys → `service_role` |
| `ANTHROPIC_API_KEY` | recomendado | console.anthropic.com → API Keys. Sin ella: motor heurístico |
| `ANALYZER_DISPATCH_TOKEN` | opcional | PAT con *Actions: Read and write* en Alertas-analyzer, para que el agente pueda pedir datos frescos |

**GitHub → Settings → Pages:** Source *Deploy from a branch*, rama `main`, carpeta `/ (root)`.

**Supabase → Edge Functions → Secrets:**
- `GH_DISPATCH_TOKEN` = PAT fine-grained con acceso a **conkosafe-agente** y permiso *Contents: Read and write*.

## Probar en local

```bash
pip install -r requirements.txt
export SUPABASE_SERVICE_ROLE_KEY=...      # y ANTHROPIC_API_KEY si quieres Claude
python agente.py --pendientes            # o --simular para forzar el motor heurístico
```

`index.html#demo` reproduce una corrida de ejemplo sin sesión.
