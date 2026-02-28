# Práctica Ingeniería de Software — Toolchain + Workflow Integrado

Este repo es una **plantilla lista** para practicar en clase:

- Issue → Rama → Pull Request → CI (GitHub Actions) → Review → Merge
- **Gates** automáticos:
  - Si cambias "arquitectura" (ej. docker-compose / infra / src/...) exige **C4 + ADR**
  - Si cambias "API" (ej. src/api / routes / controllers / endpoints) exige **OpenAPI**

## Cómo usarlo en clase (rápido)
1) Crea un repo vacío en GitHub (ej. `practica-ing-software`).
2) Sube el contenido de esta carpeta (o empuja con git).
3) Abre un PR para probar el CI y los gates.

## Probar los gates (2 PRs)
### PR 1 (API Gate)
- Crea un archivo en `src/api/` (ej. `src/api/routes.txt`) y abre PR SIN editar `docs/api/openapi.yml` → CI falla.
- Luego edita `docs/api/openapi.yml` y vuelve a push → CI pasa.

### PR 2 (Architecture Gate)
- Edita `docker-compose.yml` y abre PR SIN editar `docs/c4/` y `docs/adr/` → CI falla.
- Luego actualiza `docs/c4/contexto.mmd` y agrega un ADR en `docs/adr/` → CI pasa.

## Nota
En `.github/workflows/ci.yml` verás “Lint/Tests” como placeholder. En tu curso puedes reemplazar esos pasos por los comandos reales de tu stack.

## Ejecutar todo “de una” (sin GitHub)
Si solo quieres **correr la práctica localmente** y ver los gates fallar/pasar con un comando:

```bash
bash scripts/demo.sh
```

Opcional (si tienes Docker):
```bash
docker compose up -d
```
