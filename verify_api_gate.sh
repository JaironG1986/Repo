#!/usr/bin/env bash
set -euo pipefail

# --- Cómo funciona ---
# Este script detecta si tocaste archivos típicos de API (routes/controllers/endpoints).
# Si sí, exige que también hayas actualizado:
#   - docs/api/openapi.yml

BASE_BRANCH="${GITHUB_BASE_REF:-main}"

if git rev-parse --verify "origin/${BASE_BRANCH}" >/dev/null 2>&1; then
  BASE_REF="origin/${BASE_BRANCH}"
elif git rev-parse --verify "${BASE_BRANCH}" >/dev/null 2>&1; then
  BASE_REF="${BASE_BRANCH}"
elif git rev-parse --verify "master" >/dev/null 2>&1; then
  BASE_REF="master"
else
  BASE_REF="HEAD~1"
fi

git fetch origin "${BASE_BRANCH}" --depth=1 >/dev/null 2>&1 || true

CHANGED="$(git diff --name-only "${BASE_REF}"...HEAD || true)"

if [ -z "${CHANGED}" ]; then
  echo "✅ API Gate OK (sin cambios detectados)"
  exit 0
fi

# Ajusta estas rutas a tu proyecto real
API_TOUCH="$(echo "${CHANGED}" | egrep -i '(^src/api/|^app/api/|routes|controllers|endpoints)' || true)"

if [ -n "${API_TOUCH}" ]; then
  HAS_OPENAPI="$(echo "${CHANGED}" | egrep -i '^docs/api/openapi\.yml$' || true)"
  if [ -z "${HAS_OPENAPI}" ]; then
    echo "❌ API Gate: tocaste API pero no actualizaste docs/api/openapi.yml"
    echo ""
    echo "Cambios detectados:"
    echo "${API_TOUCH}"
    exit 1
  fi
fi

echo "✅ API Gate OK"
