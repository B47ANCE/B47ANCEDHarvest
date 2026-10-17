# Public GitHub source

Repository: https://github.com/B47ANCE/B47ANCEDHarvest (PUBLIC).

The user authorized repository creation and the 0.9.0 commit/push on 2026-10-16
(America/Phoenix). Owner B47ANCE was verified through the authenticated GitHub
CLI account. Origin uses HTTPS and contains no embedded credentials.

The initial main commit contained .gitignore; PR #1 merged the 0.9.0 source
import into main at fbcde2b1c209cba172c295f0ca4c857686121515. The hardening
iteration uses fix/harvest-0.9.1 and another PR. Commit/push requests do not
authorize merging a new PR. No stable tag, deployment, Workshop upload,
repository protection change or CI configuration is part of this iteration.

Before each public push, inspect git status --short --ignored, git diff --cached
--check, git diff --cached --stat and the complete staged text for credential
material, diagnostic logs, local settings and unintended generated files.
This import uses targeted staging of source, documentation, tests, metadata,
artwork and repository rules. dist, upload markers and developer junctions are
ignored. Hashes of historical outputs are provenance records, not their contents.

Verify identity and ancestry:

```powershell
git remote -v
git status --short --branch
git rev-parse HEAD
git ls-remote --heads origin fix/harvest-0.9.1
gh repo view B47ANCE/B47ANCEDHarvest --json visibility,url,defaultBranchRef
```

The local and remote development-branch SHA must match after push. Bootstrap main's
original SHA is 417e33ca3c7d0badbae513c9e9b6b13920cbb3db. No exact feature SHA is
embedded in its own commit; the final task report supplies remote verification.

Validation commands are in TESTING.md and VALIDATION.md. Python 3 and Lupa are
required for host fixtures; check_versions.py itself has no third-party package
dependency. Test a clean source export as well as the original workspace.

No dedicated secret-scanner executable or CI check was available/configured for
this initial import. Local staged-content and filename audits are bounded
checks, not guarantees about arbitrary future changes. No CI or static result
proves native game behavior. G7 dedicated MP NOT TESTED / BLOCKED; stable G8 BLOCKED.
