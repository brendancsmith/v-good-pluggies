#!/usr/bin/env bash
# Validate the marketplace manifest and every plugin with `claude plugin
# validate --strict`. Run by the pre-commit hook and usable by hand.
#
# When the Claude Code CLI is not on PATH this skips with a notice instead of
# failing: the marketplace and plugins are still enforced by the dedicated
# `validate` job in CI (which installs the CLI), so `pre-commit run --all-files`
# stays green in environments where `claude` is absent, such as the CI lint job.
set -euo pipefail

if ! command -v claude >/dev/null 2>&1; then
  echo "claude CLI not on PATH — skipping plugin validation (CI enforces it)."
  exit 0
fi

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

echo "Validating marketplace manifest (strict)…"
claude plugin validate --strict .

shopt -s nullglob
plugins=(plugins/*/.claude-plugin/plugin.json)
if ((${#plugins[@]} == 0)); then
  echo "No plugins defined — marketplace-only validation."
  exit 0
fi

for manifest in "${plugins[@]}"; do
  dir="$(dirname "$(dirname "$manifest")")"
  echo "Validating ${dir} (strict)…"
  claude plugin validate "$dir" --strict
done
