# B47ANCE'd Harvest version inventory

Canonical Project Version: 0.9.2.

On 2026-10-16 (America/Phoenix), the user approved the local/offline rename and
establishing canonical VERSION. Observed previous README, API and mod.info
version: 0.8.0; no root VERSION or checker existed. This pre-1.0 MINOR iteration
changes the Mod ID and therefore enabled-mod lists. It is not stable approval.

Root VERSION is the sole authority; version-inventory.json declares exact
current mirrors. VERSION_POLICY.md is the project policy. The standard checker
and policy were copied unchanged from the local team B47ANCEDPower project;
the policy identifies its framework provenance. No runtime code was copied.

Historical architecture/roadmap sections, previous changenotes, dist and
staging-backups, old ZIPs, SHA256SUMS.txt and .steamcmd-last-upload.sha256 retain
original names and versions. They are not this iteration's package/upload.
The old checksum ledger already references absent 0.1.0 and 0.4.0 ZIPs;
it is not a current distribution manifest.

versionMin is a PZ constraint, workshop version=1 a metadata format, calendar
schema v1 a storage schema, and fixture calendars/provider IDs are independent.

Run with Python 3 (Lupa is also required for host tests):
- python scripts/check_versions.py --root . --json
- python scripts/run_tests.py
- python scripts/check_versions.py --root . --release --json

The subsequent publish request authorizes a current MP test package. Its contract is
dist/current/B47ANCEDHarvest-<VERSION>-workshop-ready.zip, containing
Contents/mods/B47ANCEDHarvest/42/mod.info. scripts/build_workshop.py generates the authorized package and requires release
version checks to pass against it. Integrity/runtime checks are separate gates.

The user subsequently authorized public GitHub onboarding. The authenticated
owner is B47ANCE; public origin is https://github.com/B47ANCE/B47ANCEDHarvest.git.
The initial 0.9.0 import was merged into main through PR #1. The previous
0.9.1 hardening target was PATCH: it corrects existing behavior and adds optional receipt/inspection
fields while preserving boolean/error positions, success fields, public aliases,
provider contract, Mod ID, Workshop item and persisted schemas. Development uses
fix/harvest-0.9.1 from merged main. Verify backup with git rev-parse HEAD and
git ls-remote --heads origin fix/harvest-0.9.1. No stable tag is authorized.
docs/history/VALIDATION-0.9.0.md preserves the earlier validation separately.

## 0.9.2 cosmetic iteration

0.9.2 is PATCH: replace project thumbnail/Workshop preview using the exact
owner-supplied PNG. Gameplay, API signatures, sandbox options, IDs, persisted
schemas and small icon are unchanged. The API VERSION mirror changes only to
report the canonical version. Work starts from merged main fc4be66 on
art/harvest-0.9.2-thumbnail. This request does not authorize packaging/upload.
The published 0.9.1 outputs remain in the original checkout; this worktree has
no current package. Historical validation is retained as VALIDATION-0.9.1.md.
