#!/usr/bin/env bash
set -euo pipefail

# Demo para clase: muestra cómo fallan/pasan los gates con un solo comando.
# Uso:
#   bash scripts/demo.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

if ! command -v git >/dev/null 2>&1; then
  echo "❌ Necesitas Git instalado para correr esta demo."
  exit 1
fi

# Si no es repo git, inicializa uno
if [ ! -d ".git" ]; then
  git init >/dev/null
  git branch -M main >/dev/null 2>&1 || true
fi

# Config local (no afecta tu cuenta global)
git config user.email "demo@example.com" >/dev/null
git config user.name "Demo" >/dev/null

# Asegura main y commit inicial
git checkout -B main >/dev/null 2>&1 || git checkout main >/dev/null 2>&1 || true
git add . >/dev/null 2>&1 || true
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  git commit -m "chore: base inicial" >/dev/null
else
  # si hay cambios sin commitear, hacer commit para tener base clara
  if ! git diff --quiet || ! git diff --cached --quiet; then
    git add . >/dev/null 2>&1 || true
    git commit -m "chore: sync base" >/dev/null
  fi
fi

echo ""
echo "=============================="
echo "DEMO 1: API Gate (falla y luego pasa)"
echo "=============================="

git checkout -B demo/api >/dev/null
mkdir -p src/api
echo "dummy api change" > src/api/routes.txt
git add src/api/routes.txt
git commit -m "feat: cambio api (sin openapi)" >/dev/null

set +e
GITHUB_BASE_REF=main bash scripts/verify_api_gate.sh
STATUS=$?
set -e

if [ $STATUS -eq 0 ]; then
  echo "⚠️  Se esperaba que fallara, pero pasó. (Revisa el patrón API_TOUCH)"
else
  echo "✅ Correcto: falló porque NO actualizaste OpenAPI."
fi

echo "-> Arreglando: actualizando docs/api/openapi.yml"
echo "# cambio api demo" >> docs/api/openapi.yml
git add docs/api/openapi.yml
git commit -m "docs: update openapi" >/dev/null

GITHUB_BASE_REF=main bash scripts/verify_api_gate.sh
echo "✅ Ahora pasa el API Gate."

echo ""
echo "=============================="
echo "DEMO 2: Architecture Gate (falla y luego pasa)"
echo "=============================="

git checkout -B demo/arch >/dev/null
echo "# cambio arquitectura demo" >> docker-compose.yml
git add docker-compose.yml
git commit -m "chore: cambio arquitectura (sin docs)" >/dev/null

set +e
GITHUB_BASE_REF=main bash scripts/verify_arch_gate.sh
STATUS=$?
set -e

if [ $STATUS -eq 0 ]; then
  echo "⚠️  Se esperaba que fallara, pero pasó. (Revisa el patrón ARCH_TOUCH)"
else
  echo "✅ Correcto: falló porque NO actualizaste C4/ADR."
fi

echo "-> Arreglando: actualizando C4 + agregando ADR"
echo "C4 actualizado por demo" >> docs/c4/contexto.mmd
cat > docs/adr/ADR-0002-demo.md <<'EOF'
# ADR-0002: Demo de clase (cambio arquitectura)

## Contexto
Se modificó infraestructura (docker-compose) para practicar el gate.

## Decisión
Documentar el cambio con C4 y ADR.

## Consecuencias
El PR queda trazable y revisable.
EOF

git add docs/c4/contexto.mmd docs/adr/ADR-0002-demo.md
git commit -m "docs: C4 + ADR (demo)" >/dev/null

GITHUB_BASE_REF=main bash scripts/verify_arch_gate.sh
echo "✅ Ahora pasa el Architecture Gate."

echo ""
echo "✅ Demo terminada."
echo "   - Estás en la rama: $(git branch --show-current)"
echo "   - Puedes abrir PRs en GitHub usando estas ramas demo/* si quieres."
