#!/usr/bin/env bash
set -euo pipefail

# Publiceert AltKeeper naar GitHub en triggert unsigned IPA-build via tag.
# Vereist: gh auth login (of GH_TOKEN in omgeving)

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is niet ingelogd. Voer eerst uit: gh auth login" >&2
  exit 1
fi

REPO="${1:-Ventspew/AltKeeper}"
TAG="${2:-v1.0.0}"

if ! git remote get-url origin >/dev/null 2>&1; then
  gh repo create "$REPO" \
    --public \
    --description "Native iOS app for managing multiple game accounts (AltKeeper)" \
    --source=. \
    --remote=origin \
    --push
else
  git push -u origin main
fi

git tag -f "$TAG"
git push origin "$TAG" --force

echo ""
echo "Release $TAG gepusht naar https://github.com/$REPO"
echo "GitHub Actions bouwt AltKeeper-unsigned.ipa — volg voortgang:"
echo "  gh run list --repo $REPO"
echo "Download IPA zodra klaar:"
echo "  gh release download $TAG --repo $REPO"
