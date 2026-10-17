# B47ANCE'd Harvest rename validation

Project Version: 0.9.0

Scope: user-approved local/offline rename on 2026-10-16 (America/Phoenix).
This file records offline evidence only. No game/server was launched.

## Baseline

- [VERIFIED] The old README, API and mod.info reported 0.8.0.
- [VERIFIED] No .git, root VERSION, version inventory or existing checker.
- [UNKNOWN] GitHub freshness: Test-PZRepositoryFreshness.ps1 -Repository
  <old farmWorks root> returned UNKNOWN: not a Git repository.
- [TESTED: offline] Seven existing Lua fixtures passed before the rename.
- [TESTED: offline] The newly installed standard version checker initially
  failed because the legacy project had no version-inventory.json. This is a
  recorded onboarding gap, not a baseline PASS.

## Current checks

No former source/runtime claim is upgraded by renaming. Compatibility retains
the original API, client-authority rejection,
provider registry, diagnostic storage key and schemas. Branded entry points are
aliases; no gameplay or meaningful configuration behavior changes, so no new
sandbox setting is warranted for this identity-only iteration.

- [TESTED: offline, bundled Python/Lupa] Eight Lua host fixtures PASS, including
  new/legacy API identity, one provider registry, command aliases and the
  original diagnostic storage key.
- [TESTED: offline] Canonical 0.9.0 and all eleven current mirrors PASS the
  standard version inventory checker.
- [TESTED: offline] All fourteen runtime Lua files compile; require paths match
  exact source path case and no case collisions or Java/JAR/class files exist.
  This is source validation, not Linux runtime proof.
- [TESTED: offline] Source Mod ID/name/folder, Workshop item 3788591121 and
  public visibility verified; workshop.txt description matches the authoring
  description with actual paragraph breaks.
- [TESTED: offline] All 145 protected files match pre-rename SHA-256, including
  artwork, historical staging/packages and upload/checksum records. Portable
  baseline hashes: RENAME_PRESERVATION.json. Original path names in that ledger
  are historical; only Contents/mods/farmWorks maps to the new source folder.
- [TESTED: local workspace] Four workspace selectors now target the renamed
  directory; each workspace JSON parses successfully.
- [TESTED: offline] Release version check correctly FAILS because no current
  package exists. That expected gate failure is not a failed source mirror.

## Runtime gates and backup

- [RUNTIME GATE] Changed Mod ID requires re-enabling/updating enabled-mod lists.
  Do not enable old and new identities together.
- [RUNTIME GATE] Existing save, subscription/download, native calendar, hosted,
  dedicated join/rejoin, synchronization, persistence and restart checks remain.
- G7: dedicated multiplayer NOT TESTED / BLOCKED.
- G8: stable release BLOCKED. No current package is built.
- The earlier local rename had no Git backup. Public GitHub onboarding was
  subsequently authorized for B47ANCE/B47ANCEDHarvest; the initial source import
  uses feature/harvest-0.9.0 with a PR into main. Verify pushed SHA as described
  in GITHUB.md; a GitHub push is not runtime or release evidence.
- Deploy/publish: not requested, not performed. Workshop ID/visibility unchanged.

## Verification commands

Bundled Python:
C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe

Run with that interpreter:
- scripts/check_versions.py --root . --json
- scripts/run_tests.py
- scripts/check_identity.py
- scripts/check_identity.py --require-local-history (original workspace only)
- scripts/check_versions.py --root . --release --json

Historical outputs, artwork and upload ledgers have a pre-rename SHA-256
preservation ledger outside the source tree and a portable copy in
RENAME_PRESERVATION.json. check_identity.py compares every original entry with
its current location, accounting only for the renamed active mod directory.
No artifact cleanup or repackaging is part of this change.

## Public-checkout validation

By default, check_identity.py verifies every available protected historical file
and requires the source artwork, Workshop ID and checksum ledger. Missing ignored
dist outputs and the local upload marker are explicitly reported as omitted,
not passed. --require-local-history requires all 145 files in the original
workspace. Public exports therefore do not need private local build artifacts.

[TESTED: offline, Git tree export] Version checks, all eight Lua fixtures and
portable identity checks PASS in an isolated export of the staged source tree.
Five portable protected files retain their SHA-256; 140 absent local output
files are reported as omitted. The original workspace strict check still
passes all 145 entries. [TESTED: staged audit] All 52 UTF-8 files and three PNGs
were inspected for excluded filenames and high-confidence credential patterns;
no findings. git diff --cached --check PASS. This is a bounded local audit;
no CI or dedicated scanner result is claimed.
