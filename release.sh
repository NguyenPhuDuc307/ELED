#!/usr/bin/env bash
# Usage:
#   ./release.sh              — auto-increment alpha (alpha.7 → alpha.8)
#   ./release.sh 8            — set alpha number explicitly
#   ./release.sh 8 "note"     — with custom release note
#   ./release.sh -f           — overwrite current version (no new commit)
#   ./release.sh -f 8         — overwrite specific alpha number
#   ./release.sh --bundle     — also build + attach AAB (for Play Store / Play App Signing)
set -euo pipefail

# ── Parse flags ───────────────────────────────────────────────────────────────
FORCE=false
BUNDLE=false
ARGS=()
for arg in "$@"; do
  if [ "$arg" = "-f" ] || [ "$arg" = "--force" ]; then
    FORCE=true
  elif [ "$arg" = "--bundle" ] || [ "$arg" = "-b" ]; then
    BUNDLE=true
  else
    ARGS+=("$arg")
  fi
done

CURRENT=$(grep '^version:' pubspec.yaml | sed 's/version: //')
CURRENT_ALPHA=$(echo "$CURRENT" | grep -oE 'alpha\.[0-9]+' | grep -oE '[0-9]+')

if [ ${#ARGS[@]} -ge 1 ]; then
  ALPHA="${ARGS[0]}"
elif [ "$FORCE" = true ]; then
  ALPHA="$CURRENT_ALPHA"   # overwrite: keep same number
else
  ALPHA=$((CURRENT_ALPHA + 1))
fi

EXTRA_NOTE="${ARGS[1]:-}"

VERSION="1.0.0-alpha.${ALPHA}+${ALPHA}"
TAG="v1.0.0-alpha.${ALPHA}"
TITLE="Alpha ${ALPHA}"
APK_NAME="eled-alpha${ALPHA}.apk"
APK_SRC="build/app/outputs/flutter-apk/app-release.apk"
APK_DST="build/app/outputs/flutter-apk/${APK_NAME}"
AAB_NAME="eled-alpha${ALPHA}.aab"
AAB_SRC="build/app/outputs/bundle/release/app-release.aab"
AAB_DST="build/app/outputs/bundle/release/${AAB_NAME}"

echo "══════════════════════════════════════════"
if [ "$FORCE" = true ]; then
  echo "  Overwriting  ${TAG}"
else
  echo "  Releasing    ${TAG}"
fi
echo "══════════════════════════════════════════"

if [ "$FORCE" = true ]; then
  # ── Delete existing release + tag ─────────────────────────────────────────
  if gh release view "$TAG" &>/dev/null; then
    gh release delete "$TAG" --yes
    echo "✓ Deleted GitHub release ${TAG}"
  fi
  if git ls-remote --tags origin | grep -q "refs/tags/${TAG}$"; then
    git push origin ":refs/tags/${TAG}"
    echo "✓ Deleted remote tag ${TAG}"
  fi
  if git tag | grep -q "^${TAG}$"; then
    git tag -d "$TAG"
    echo "✓ Deleted local tag ${TAG}"
  fi
else
  # ── Bump version & commit ────────────────────────────────────────────────
  sed -i '' "s/^version: .*/version: ${VERSION}/" pubspec.yaml
  echo "✓ pubspec.yaml → ${VERSION}"
  git add -A
  git commit -m "release alpha ${ALPHA}

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
  git push origin main
  echo "✓ Pushed to main"
fi

# ── Build APK ─────────────────────────────────────────────────────────────────
echo "Building APK…"
flutter build apk --release
cp "$APK_SRC" "$APK_DST"
echo "✓ Built ${APK_NAME}"

# ── Optionally build AAB ──────────────────────────────────────────────────────
RELEASE_ASSETS=("$APK_DST")
if [ "$BUNDLE" = true ]; then
  echo "Building AAB…"
  flutter build appbundle --release
  cp "$AAB_SRC" "$AAB_DST"
  echo "✓ Built ${AAB_NAME}"
  RELEASE_ASSETS+=("$AAB_DST")
fi

# ── Build release notes ───────────────────────────────────────────────────────
NOTES="## Alpha ${ALPHA}"
if [ -n "$EXTRA_NOTE" ]; then
  NOTES="${NOTES}

${EXTRA_NOTE}"
fi

# ── GitHub release ────────────────────────────────────────────────────────────
gh release create "$TAG" \
  --title "$TITLE" \
  --notes "$NOTES" \
  --prerelease \
  "${RELEASE_ASSETS[@]}"

echo ""
echo "✓ Done: https://github.com/NguyenPhuDuc307/ELED/releases/tag/${TAG}"
