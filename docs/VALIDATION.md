# Harvest mod icon validation

Project Version: 0.9.3

Cosmetic PATCH from PR #4 merge 244a446. Prior validation is preserved byte for
byte in history/VALIDATION-0.9.2.md. The user selects the generated transparent
trowel/seed-packet icon, requires unchanged thumbnails, and authorizes PR merges
and publication after checks. No game/server launch or local deploy requested.

## Source and ownership

The runtime icon stays at Contents/mods/B47ANCEDHarvest/42/icon.png and its
existing 32 x 32 dimensions. Keep the original generated RGBA PNG and prompt
under assets/branding/. Export with Pillow 12.3.0 Image.Resampling.LANCZOS,
optimized PNG compression level 9. Preserve the old icon in assets/history/.
ARTWORK.json binds the source, export and historical icon hashes. The original
RENAME_PRESERVATION.json remains unchanged; checks follow the historical copy
for the superseded icon rather than weakening its original hash requirement.

Mod info still uses icon=icon.png and poster=thumbnail.png. Installed vanilla
ModListBox scales the selected icon to button dimensions; ModOrderListBox
renders it at 28 x 28. These source observations do not prove game rendering.
The only production Lua change is its VERSION mirror. Gameplay authority,
APIs, sandbox settings, Mod ID, Workshop item and saved schemas are unchanged.
No new gameplay setting is introduced for this presentation-only asset.

## Exact validation commands

Use Python 3 with Lupa 2.8 for host checks:

- python scripts/check_versions.py --root . --json
- python scripts/check_identity.py
- python scripts/run_tests.py
- python scripts/run_tests.py --lua51
- git diff --check
- git diff --cached --check
- shared tools/Test-PZRepositoryFreshness.ps1 -Repository <worktree>
- python scripts/build_workshop.py --game-root <verified installed PZ root>
- python scripts/check_versions.py --root . --release --json

[TESTED: offline, Windows] Version/identity checks and nine fixtures on Lua 5.4
and Lua 5.1 pass. PNG hashes, RGBA structure, actual alpha/corners and decode
checks pass. Thumbnail and Workshop preview are byte-identical to merged
0.9.2 source. The previous icon and validation match merged source. Five
portable protected entries pass; 140 absent local historical entries are not
validated in this clean worktree. All fourteen Lua sources compile with
case-correct require paths; this is not Linux or native-game proof.

## Publication and runtime limits

Build a clean committed package from main after authorized PR merges. The
packager verifies source/staging/member hashes, traversal/duplicate/case/CRC
integrity, preview size/hash and release versions. The ignored release manifest
binds version, source commit, Mod ID, Workshop item, package/member hashes,
installed Steam build and evidence limits. Upload result is recorded separately.
Previous 0.9.1/0.9.2 staging and upload evidence remain intact in other checkouts.

[RUNTIME GATE] Native icon/mod-selector rendering, Workshop display and SP or
dedicated gameplay scenarios remain NOT TESTED. G7 BLOCKED / NOT TESTED and
stable-release G8 BLOCKED remain unchanged. An upload is test distribution,
not runtime proof. Steam desktop restart needs a specific affirmative reply
following this upload's verified success.
