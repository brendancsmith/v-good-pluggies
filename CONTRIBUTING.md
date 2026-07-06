# Contributing

Contributions are welcome!

See the official documentation:

- [Create plugins](https://code.claude.com/docs/en/plugin-marketplaces)
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- [Create and distribute a plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces)

## Layout

```text
.claude-plugin/marketplace.json  # marketplace manifest — lists the available plugins
plugins/
  <plugin>/
    .claude-plugin/plugin.json   # plugin manifest (name, description, version)
    .lsp.json                    # language server configs
    .mcp.json                    # MCP server configs
    agents/<name>.md             # an agent definition → @<plugin>:<name>
    bin/                         # executables added to the Bash PATH
    commands/<name>.md           # a slash command → /<plugin>:<name>
    hooks/hooks.json             # event handlers (SessionStart PreToolUse, PostToolUse, …)
    monitors/monitors.json       # background monitors
    output-styles/<name>.md      # customizations for Claude's role, tone, and response format
    settings.json                # default configs when plugin is loaded (limited set)
    scripts/                     # helper scripts referenced via ${CLAUDE_PLUGIN_ROOT}
    skills/<name>/SKILL.md       # a skill entry point → /<plugin>:<name>
```

Every plugin component is optional and only the pieces a plugin actually uses
need to exist.

The default component paths can be changed in `plugin.json`. Note
that some path fields (e.g. `commands`) are *overrides*, others (e.g. `skills`
are path *additions*, others support *inline configuration* (e.g. `hooks`), and
others are unavailable (e.g the paths `bin` and `scripts` are fixed).

Bundled scripts, binaries, and configs can use `${CLAUDE_PLUGIN_ROOT}` to
reference their location.

## Setup

Markdown is linted by
[`markdownlint-cli2`](https://github.com/DavidAnson/markdownlint-cli2) through
[pre-commit](https://pre-commit.com), reading the rules in `.markdownlint.yaml`.
Install the hook once per clone:

```zsh
uv tool install pre-commit          # user-wide, once
pre-commit install --install-hooks  # per clone — installs .git/hooks/pre-commit
```

Every commit then lints staged Markdown and blocks on violations. Run
`pre-commit run --all-files` to check the whole tree. The hook only reports
issues — fix them in your editor's markdownlint integration, then re-commit.

## Adding a plugin

1. Create `plugins/<plugin>/.claude-plugin/plugin.json` with at least `name`
   and `description`. Also set `version`, `author`, `license`, and, if
   relevant, `homepage`/`repository`/`keywords`.
2. Add whichever components the plugin needs (see [Layout](#layout) above).
3. List the plugin in `.claude-plugin/marketplace.json`, with a `source`
   pointing at `./plugins/<plugin>`.
4. Add a row for it in the README's Plugins table.

## Naming

Plugin names (in both `plugin.json` and `marketplace.json`) are kebab-case —
lowercase letters, digits, and hyphens only, no spaces or uppercase — and must
match between the two files.

## Versioning

Both `marketplace.json` and each plugin's `plugin.json` carry a `version`
field. Bump each following semver (`major.minor.patch`).

### `marketplace.json`

The top-level `version` has no functional effect — it doesn't gate updates or
invalidate caches. It's informational only, describing this repo as a whole:

- **major** — a plugin removed, or renamed without a `renames` entry, or a
  restructure that breaks existing installs.
- **minor** — a plugin added, or renamed with a `renames` entry (existing
  installs auto-migrate, so it's non-breaking).
- **patch** — any other manifest-only tweak (metadata, description, etc.).

Bump it as a matter of convention for diagnosing marketplace installations.

### `plugin.json`

Each plugin's own `version` drives update detection — it's what
`claude plugin marketplace update` compares to decide whether a user gets a
new release. Bump it on every release that changes the plugin:

- **major** — a removed or renamed command/skill/agent, or a changed
  required config field.
- **minor** — a backward-compatible addition (new command/skill/agent).
- **patch** — a fix with no new or removed surface area.

Omitting `version` entirely means every git commit to the plugin counts as a
new version instead.

## Testing locally

Load a plugin directly from its working directory, without installing it from
the marketplace, for the length of one session:

```zsh
claude --plugin-dir plugins/<plugin>
```

`/reload-plugins` picks up further edits without restarting the session. To
test marketplace resolution itself (`source` paths, cross-plugin references),
add this repo as a local marketplace instead:

```zsh
claude plugin marketplace add .
claude plugin install <plugin>@v-good-pluggies
```

## Validating

Before opening a PR, validate every plugin you touched:

```zsh
claude plugin validate plugins/<plugin> --strict
```

`--strict` also flags unrecognized fields, which the default (non-strict) run
lets through as warnings.

## Style

- Markdown is linted per `.markdownlint.yaml`; keep prose and code fences
  consistent with the existing plugins.
- JSON manifests: 2-space indent, no trailing commas.

## Commits and pull requests

- One logical change per commit; keep plugin-specific changes separate from
  marketplace- or repo-wide changes.
- Use conventional-commit-style messages (`feat:`, `fix:`, `docs:`, `chore:`,
  …) and branch names (`feature/<slug>`, `fix/<slug>`, …).
- Open PRs against `main`. Mention which command you ran to validate
  (`claude plugin validate`) in the PR description.
