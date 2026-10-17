# B47ANCE'd Harvest hardening validation

Project Version: 0.9.1

Scope: eight audited defects from 0.9.0, corrected on fix/harvest-0.9.1.
Prior evidence is archived unchanged in history/VALIDATION-0.9.0.md.
No game/server was launched. All PASS statements below are offline checks.

## Baseline and regressions

- [VERIFIED] Start commit fbcde2b1c209cba172c295f0ca4c857686121515, merged main;
  startup freshness PASS with a clean tree and zero divergence.
- [TESTED: offline] Existing eight fixtures PASS on 0.9.0. The newly added
  hardening fixture reproduced all eight regression-group failures before fixes.
- [TESTED: offline, Windows/Lupa Lua 5.4] Nine fixtures PASS after fixes.
- [TESTED: offline, Windows/Lupa Lua 5.1] The same nine fixtures PASS; this is
  host language compatibility, not Kahlua or native-game execution.

The eight groups cover unknown/client mutation authority; provider partial,
rejected, mismatched, malformed, changed-provider and unavailable readback;
furrow classification; authoritative season disable/unknown configuration;
optional malformed month arrays; invalid calendar days; incompatible native
calendars while retaining custom-window support; and failed registrations not
consuming quota/IDs. The quota ceiling and valid year-wrap behavior still pass.

## Source evidence and ownership

Installed Steam build: 25485521. Exact full game version: UNKNOWN in this pass.
- [VERIFIED] SPlantGlobalObject initializes new furrows as plow/none-seed, while
  its isAlive predicate also accepts that state; the provider now excludes it.
- [VERIFIED] Native ISFarmingMenu reads PlantGrowingSeasons through the same
  sandbox-options accessor used by the new adapter. Source fingerprint:
  c3c9413f414f49f0e9639361d2bfb79397d023d30cdd80d566d5293c364948c3.
- [VERIFIED] Native ten-point watering/saveData source is unchanged; see
  IRRIGATION_RUNTIME_AUDIT.md for fingerprint and exact source spans.
- Client intent/networking is not added. Unknown realm rejects; server/SP calls
  use verified native crop mutation. Source withdrawal remains waterWorks-owned.
- Receipts are transient and additive, not a persistence/schema migration or
  atomic source-water transaction. No safe automatic retry/rollback is claimed.
- Configuration assessment: use the existing native PlantGrowingSeasons option.
  Safety checks, Gregorian/provider IDs and technical page/registry limits do not
  introduce meaningful new gameplay settings and remain internal contracts.

## Additional checks

- [TESTED: offline] Canonical 0.9.1 and all eleven declared current mirrors
  PASS; historical records retain their original version labels.
- [TESTED: offline] All fourteen runtime Lua sources compile, require paths
  match source case, and no source case collisions or Java/JAR/class files exist.
  Static case validation is not Linux runtime proof.
- [TESTED: original workspace] Identity/Workshop-description parity PASS and all
  145 protected historical/artwork/upload/checksum files retain their SHA-256.
- [TESTED: isolated Git export] Version/identity checks and all nine fixtures
  PASS on both Lua 5.4 and 5.1 hosts. Five portable protected files match hashes;
  the 140 omitted local output files are explicitly not validated in the export.
- [TESTED: staged public-file audit] All 55 UTF-8 files and three PNG assets
  scanned for credential patterns and excluded filenames; no findings.
  git diff --cached --check PASS. No dedicated scanner/CI result is claimed.
- [TESTED: release gate] --release correctly fails only for the absent current
  package. This does not invalidate the passing source-version mirrors.
- [VERIFIED] Archived history/VALIDATION-0.9.0.md matches the previous main
  validation content; no prior runtime evidence is relabeled as current.

## Exact validation commands

Use Python 3 with Lupa. This workspace's interpreter:
C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe

Arguments run from the project root:
- scripts/check_versions.py --root . --json
- scripts/run_tests.py
- scripts/run_tests.py --lua51
- scripts/check_identity.py
- scripts/check_identity.py --require-local-history
- scripts/check_versions.py --root . --release --json

Git checks:
- git diff --cached --check
- git status --short --ignored
- shared tools/Test-PZRepositoryFreshness.ps1 -Repository <project root>
- git rev-parse HEAD
- git ls-remote --heads origin fix/harvest-0.9.1

## Runtime and release gates

[RUNTIME GATE] Native startup, SP save/reload, server-authoritative option
agreement, hosted/dedicated joining/rejoining, crop replication and restarts
remain untested. See TESTING.md and IRRIGATION_API.md for scenarios.
G7: dedicated multiplayer NOT TESTED / BLOCKED. Stable-release G8: BLOCKED.
No current package, deployment, Workshop upload, merge or stable tag authorized
by this iteration's commit/push request. Historical assets/packages are preserved.
