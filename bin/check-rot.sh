#!/bin/bash
# Check this patch series against the current av2-enc head.
#
# WHAT THIS TOOL DOES AND DOES NOT TELL YOU
#
# It tells you whether each patch still *applies textually*. That is a necessary
# condition for the series to be usable, and it is cheap, so it is worth running
# before every round.
#
# It does NOT tell you the patches are still *correct*. Those are different
# questions and conflating them is the trap this file exists to warn about.
# A worked example from this series:
#
#   av2-enc moved a341351 -> 425711f, a single commit: "Implement non-RD
#   partition evaluation for real-time mode (#5236)". It added 187 lines to
#   av2/encoder/partition_search.c. Patches 0006 and 0007 modify that same
#   file. All ten patches still reported APPLIES -- because the new code landed
#   in regions the patches do not touch textually.
#
#   But 0006 and 0007 prune partition search. If the new real-time partition
#   path bypasses the hook they attach to, they silently stop doing anything on
#   that path. If it routes through the hook, they silently start pruning a
#   search they were never measured against. Either way "APPLIES" is true and
#   meaningless.
#
# So: a clean apply after an upstream move justifies re-running the cheap tiers,
# it does not substitute for them. On any base change, re-run Tier 0
# (bit-exactness, minutes) and Tier 1 (instruction counts) before trusting any
# previously recorded number. Measurements are only valid against the base SHA
# they were taken on, which is why BASE is tracked in this repo.
#
# Usage:
#   bin/check-rot.sh /path/to/avm-checkout [target-ref]
# Default target-ref is origin/av2-enc.

set -u
AVM="${1:?usage: check-rot.sh /path/to/avm-checkout [ref]}"
REF="${2:-origin/av2-enc}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PATCHDIR="$HERE/patches"
BASEFILE="$HERE/BASE"

[ -d "$AVM/.git" ] || { echo "not a git checkout: $AVM" >&2; exit 1; }

cd "$AVM" || exit 1
git fetch -q origin "${REF#origin/}" 2>/dev/null
HEAD_SHA=$(git rev-parse "$REF" 2>/dev/null) || { echo "no such ref: $REF" >&2; exit 1; }
BASE_SHA=$(tr -d '[:space:]' < "$BASEFILE" 2>/dev/null)

echo "series base : ${BASE_SHA:-<unset>}"
echo "$REF head   : $HEAD_SHA"

if [ "$BASE_SHA" = "$HEAD_SHA" ]; then
  echo "status      : up to date, nothing moved"
  DRIFT=0
else
  DRIFT=$(git rev-list --count "$BASE_SHA..$HEAD_SHA" 2>/dev/null || echo "?")
  echo "status      : $DRIFT commit(s) upstream of the recorded base"
  echo
  echo "files changed upstream that this series also touches:"
  # The overlap set is where a clean apply is least trustworthy.
  comm -12 \
    <(git diff --name-only "$BASE_SHA..$HEAD_SHA" | sort -u) \
    <(grep -h -oP '^\+\+\+ b/\K.*' "$PATCHDIR"/*.patch 2>/dev/null | sort -u) \
    | sed 's/^/  /' || true
fi
echo

# Apply each patch against a detached checkout of the target ref. Restore the
# caller's original HEAD unconditionally, including on interrupt -- leaving a
# colleague's working tree detached would be a rude way to fail.
ORIG=$(git symbolic-ref -q --short HEAD || git rev-parse HEAD)
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "working tree is dirty; refusing to detach. Commit or stash first." >&2
  exit 1
fi
restore() { git checkout -q "$ORIG" 2>/dev/null; }
trap restore EXIT INT TERM

git checkout -q --detach "$HEAD_SHA" || exit 1

rc=0
printf '%-44s %s\n' "patch" "applies against $REF"
printf '%-44s %s\n' "$(printf '%.0s-' {1..44})" "--------------------"
for p in "$PATCHDIR"/*.patch; do
  [ -e "$p" ] || continue
  n=$(basename "$p" .patch)
  if git apply --check "$p" 2>/dev/null; then
    v="APPLIES"
  elif git apply --3way --check "$p" 2>/dev/null; then
    v="NEEDS-3WAY"; rc=1
  else
    v="FAILS"; rc=1
  fi
  printf '%-44s %s\n' "$n" "$v"
done

echo
if [ "$DRIFT" != "0" ]; then
  cat <<'EOF'
The base moved. Every measurement in experiments/registry.csv was taken against
the OLD base and is not automatically valid against this one. Before the next
round: update BASE, re-run Tier 0 (bit-exactness) and Tier 1 (instruction
counts), and only then treat the numbers as current.
EOF
fi
exit $rc
