## Summary

<!-- What does this change, and why? -->

## Type of change

- [ ] New plugin
- [ ] Change to an existing plugin
- [ ] Marketplace / repo tooling or docs

## Checklist

- [ ] `pre-commit run --all-files` passes (markdownlint + manifest checks)
- [ ] `claude plugin validate <plugin> --strict` passes for any plugin I touched
- [ ] Bumped the affected plugin's `version` in `plugin.json` and its marketplace entry per semver
- [ ] Bumped the marketplace `version` in `marketplace.json` if necessary.
- [ ] Added or updated the plugin's row in the README table
- [ ] Docs reflect the current behavior
