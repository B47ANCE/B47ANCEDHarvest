# Harvest Workshop MP test publishing

Canonical inputs: root WORKSHOP_DESCRIPTION.txt and WORKSHOP_CHANGE_NOTE.txt,
workshop.txt, VERSION, WORKSHOP_ID.txt, preview.png and authoritative Contents/
mods/B47ANCEDHarvest. Keep their established BBCode and paragraph breaks.

The prior 0.9.1 MP test upload succeeded. A subsequent explicit publish request
authorizes packaging and distribution of the cosmetic 0.9.2 iteration to the
same item. Preflight must verify the current source and upload preview. Prior
upload evidence is not proof of this artwork being distributed. The supplied
PNG exceeds Steam's preview size limit; the uploader must use a validated
export below 1,000,000 bytes while preserving the full-resolution original.
The user approved a smaller PNG using local image tools. Current preview:
960 x 960, 954,246 bytes; hash/dimensions/source are in docs/ARTWORK.json.
Regenerate with `python scripts/export_preview.py` using developer-only
Pillow 12.3.0. The export helper never uploads or edits the original mod
thumbnail. Packaging uses the committed export and refuses oversized or
hash-mismatched previews. Steamworks reference:
https://partner.steamgames.com/doc/api/isteamugc?language=english

Build from a clean, committed, freshly verified branch containing merged main.
Do not create a new item, change visibility, create a stable tag, deploy or
launch a server as part of packaging.

Run with Python 3 and developer-only Lupa from scripts/requirements-tests.txt.
The test runner explicitly selects Lua 5.4 (or --lua51) rather than depending
on Lupa's default host. The publication pass uses an isolated local test venv;
no Python dependency is shipped in the mod.

Build command:

    python scripts/build_workshop.py --game-root <verified installed PZ root>

The packager runs both host suites, source/identity/version checks, builds the
versioned workshop-ready ZIP, verifies member paths/case/CRC/content hashes,
and runs --release version checks against the actual archive. It never uploads,
deletes old artifacts, executes downloaded mods or launches Steam. Existing
dist/current content blocks another build; retention is a separate operation.
Committed Git blobs supply package bytes for consistent newline provenance.

Generated, ignored outputs: dist/current/staging, the versioned ZIP, upload.vdf
and release-manifest.json. SteamCMD contentfolder points at staging/Contents
so the downloaded item contains mods/B47ANCEDHarvest; the ZIP contains the
authoring Contents directory. Only the current changenote section is selected.
The manifest binds source Git SHA, Mod ID, item 3788591121, App ID 108600,
archive/member hashes, exact installed Steam build and validation limits.

Description and change note must contain:
MP testing build - dedicated multiplayer NOT TESTED

The public GitHub source link is verified against origin. Actual game/native,
SP and dedicated tests are not inferred from host checks. G7 BLOCKED / NOT
TESTED and stable G8 BLOCKED remain in force after successful distribution.

The discovered legacy Farmworks VDF selects the same item but references a
removed path; preserve it and use the newly verified staging VDF. Invoke the
verified developer-local SteamCMD with its existing cached login and the exact
nonzero publishedfileid. No passwords/keys enter this repository. The new VDF
omits visibility and tags so existing Workshop settings are preserved.

No active uploader wrapper is reused because none is present in this checkout.
The direct SteamCMD operation has no post-upload desktop/client commands.
Success requires SteamCMD's explicit result for item 3788591121, not exit code
alone. Preserve a local upload result and verify the live page when accessible.
Public lookups currently do not expose the item; that verification gap must
remain explicit.

The prior ZIP, staging backups and upload/checksum records are historical
recovery evidence. They retain their original Mod ID/version. A rollback to
farmWorks would require enabled-mod-list changes and is not save-compatible
proof; do not silently relabel or republish an old archive.

After verified upload success, ask for this specific Steam desktop restart and
wait for an affirmative answer. Publish alone does not authorize that restart.
