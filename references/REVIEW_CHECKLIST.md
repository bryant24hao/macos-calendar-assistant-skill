# Review Checklist (pre-release)

## Safety
- [ ] Destructive actions require explicit `--apply`
- [ ] Default path is dry-run/non-destructive where possible
- [ ] Error messages are human-readable

## Idempotency
- [ ] Same event write does not duplicate
- [ ] Update path only changes intended fields
- [ ] Calendar routing is deterministic

## Portability
- [ ] No hardcoded `/Users/<name>/...` in scripts
- [ ] Script paths are relative to skill directory
- [ ] Config values can override defaults

## Observability
- [ ] Outputs include machine-parseable status (`CREATED/UPDATED/SKIPPED`)
- [ ] Duplicate scan outputs valid JSON
- [ ] Cron output/log path documented

## Permissions
- [ ] Calendar permission failure handled clearly
- [ ] README/SKILL mention macOS-only requirement

## Packaging readiness
- [ ] `SKILL.md` frontmatter has only `name` + `description`
- [ ] Required scripts are executable
- [ ] `scripts/install.sh` and `scripts/uninstall.sh` work
