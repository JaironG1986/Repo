#!/usr/bin/env bash
set -euo pipefail

# --- Cómo funciona ---
# Este script detecta si tu PR/cambio tocó "arquitectura" (infra/código base).
# Si sí, exige que también hayas actualizado:
#   - docs/c4/   (diagramas)
#   - docs/adr/  (decisiones)
#
# En GitHub Actions se usa GITHUB_BASE_REF automáticamente.
# En local, hace fallback a main/master/HEAD~1.

BASE_BRANCH="${GITHUB_BASE_REF:-main}"

# Decide qué referencia usar como base para el diff
if git rev-parse --verify "origin/${BASE_BRANCH}" >/dev/null 2>&1; then
  BASE_REF="origin/${BASE_BRANCH}"
elif git rev-parse --verify "${BASE_BRANCH}" >/dev/null 2>&1; then
  BASE_REF="${BASE_BRANCH}"
elif git rev-parse --verify "master" >/dev/null 2>&1; then
  BASE_REF="master"
else
  BASE_REF="HEAD~1"
fi

# No fallar si no existe origin (en local)
git fetch origin "${BASE_BRANCH}" --depth=1 >/dev/null 2>&1 || true

CHANGED="$(git diff --name-only "${BASE_REF}"...HEAD || true)"

# Si no hay cambios (o no hay historial), pasa
if [ -z "${CHANGED}" ]; then
  echo "✅ Architecture Gate OK (sin cambios detectados)"
  exit 0
fi

# Ajusta estas rutas a tu proyecto real
ARCH_TOUCH="$(echo "${CHANGED}" | egrep -i '(^src/|^app/|^services/|^infra/|^docker-compose\.yml|^k8s/|^terraform/)' || true)"

if [ -n "${ARCH_TOUCH}" ]; then
  HAS_ADR="$(echo "${CHANGED}" | egrep -i '^docs/adr/' || true)"
  HAS_C4="$(echo "${CHANGED}" | egrep -i '^docs/c4/' || true)"

  if [ -z "${HAS_ADR}" ] || [ -z "${HAS_C4}" ]; then
    echo "❌ Architecture Gate: tocaste arquitectura pero falta ADR y/o C4."
    echo "   - Agrega/actualiza /docs/adr/..."
    echo "   - Actualiza /docs/c4/..."
    echo ""
    echo "Cambios detectados:"
    echo "${ARCH_TOUCH}"
    exit 1
  fi
fi

echo "✅ Architecture Gate OK"
