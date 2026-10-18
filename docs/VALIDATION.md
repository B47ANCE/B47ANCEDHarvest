# Harvest artwork validation

Project Version: 0.9.2

Scope: cosmetic PATCH on art/harvest-0.9.2-thumbnail from merged main fc4be66.
The owner supplied the image on 2026-10-17. Historical 0.9.1 validation is
preserved byte for byte at history/VALIDATION-0.9.1.md; it is not current proof.

## Change and invariants

Copy the supplied PNG without editing/re-encoding to preview.png and
Contents/mods/B47ANCEDHarvest/thumbnail.png. Both are 1254 x 1254, 1,697,917
bytes; SHA-256 is recorded in ARTWORK.json. Keep the previous image under
assets/history/thumbnail-before-0.9.2.png and validate it against the original
RENAME_PRESERVATION.json hashes. That original evidence manifest is unchanged.

The small icon, Mod ID, Workshop item, public API signatures, sandbox settings,
server authority and persisted schemas are unchanged. The only runtime Lua diff
is the canonical VERSION mirror. Artwork introduces no gameplay configuration.

## Validation commands

Run with Python 3 and developer-only Lupa 2.8:

- python scripts/check_versions.py --root . --json
- python scripts/check_identity.py
- python scripts/run_tests.py
- python scripts/run_tests.py --lua51
- git diff --check
- shared tools/Test-PZRepositoryFreshness.ps1 -Repository <worktree>

[TESTED: offline, Windows] Version mirrors, source identity, Lua syntax/require
case and supplied-image hashes/dimensions pass. PNG chunk CRCs and image-data
decompression pass. The old image and validation document match merged main.
The five portable protected entries pass using the old-art archive; 140 local
historical output entries are absent from this clean worktree and not validated.

[TESTED: offline] All nine fixtures pass on explicit Lua 5.4 and Lua 5.1 hosts.
These are language-host tests, not PZ/Kahlua, SP or dedicated execution.

## Distribution and runtime limits

The prior 0.9.1 Workshop upload succeeded; this does not distribute 0.9.2.
No new package, deployment, Workshop upload or Steam restart was requested.
No --release package check is claimed for this source-only iteration. Published
0.9.1 staging and upload records remain intact in the original checkout.
A future publication must validate the new preview against uploader requirements.

[RUNTIME GATE] Mod-selector rendering, Workshop display and all SP/dedicated
runtime scenarios remain NOT TESTED. No game/server was launched. G7 remains
BLOCKED / NOT TESTED and stable-release G8 remains BLOCKED.
