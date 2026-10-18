"""Build and verify committed Workshop staging; never uploads, deploys or launches Steam."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]
MOD = "B47ANCEDHarvest"
ITEM = "3788591121"
LABEL = "MP testing build - dedicated multiplayer NOT TESTED"


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def committed(name):
    return git("show", "HEAD:" + name)


def quote(text):
    # Preserve real paragraph breaks in Valve KeyValues strings.
    return '"' + text.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game-root", required=True, type=Path)
    args = parser.parse_args()
    if git("status", "--porcelain").strip():
        raise SystemExit("Commit and verify source first; uncommitted payload is refused.")
    for command in (["scripts/check_versions.py", "--root", ".", "--json"],
                    ["scripts/run_tests.py"], ["scripts/run_tests.py", "--lua51"],
                    ["scripts/check_identity.py"]):
        subprocess.run([sys.executable, *command], cwd=ROOT, check=True)
    version = committed("VERSION").decode().strip()
    assert committed("WORKSHOP_ID.txt").decode().strip() == ITEM
    desc = committed("WORKSHOP_DESCRIPTION.txt").decode("utf-8")
    notes = committed("WORKSHOP_CHANGE_NOTE.txt").decode("utf-8").split("[b]Historical", 1)[0].strip() + "\n"
    for text in (desc, notes):
        assert LABEL in text and "\\n" not in text and text.strip()
        assert not re.search(r"\b(?:TODO|TBD|PLACEHOLDER)\b", text)
    assert "https://github.com/B47ANCE/B47ANCEDHarvest" in desc
    # Steamworks k_cchPublishedDocumentDescriptionMax includes the terminator.
    assert len(desc.encode("utf-8")) < 8000, "Description exceeds Steamworks bound"
    entries = {}
    prefix = "Contents/mods/" + MOD + "/"
    for name in git("ls-files", "-z").decode().split("\0"):
        if name.startswith(prefix) and not name.endswith("/.keep"):
            entries[name] = committed(name)
    for name in ("preview.png", "workshop.txt"):
        entries[name] = committed(name)
    artwork = json.loads(committed("docs/ARTWORK.json"))
    preview = artwork["workshop_export"]
    assert preview["path"] == "preview.png"
    assert len(entries["preview.png"]) == preview["bytes"] < 1_000_000, "Workshop preview exceeds size limit"
    assert sha(entries["preview.png"]) == preview["sha256"], "Workshop preview differs from reviewed export"
    assert entries and (prefix + "42/mod.info") in entries
    info = entries[prefix + "42/mod.info"].decode("utf-8")
    assert re.search(r"^id=" + MOD + "$", info, re.M)
    assert re.search(r"^modversion=" + re.escape(version) + "$", info, re.M)
    folded = set()
    for name in entries:
        path = PurePosixPath(name)
        assert not path.is_absolute() and ".." not in path.parts and "\\" not in name
        assert name.casefold() not in folded, name
        assert path.suffix.lower() not in (".java", ".jar", ".class", ".dll", ".exe", ".log"), name
        folded.add(name.casefold())
    output = ROOT / "dist/current"
    if output.exists() and any(output.iterdir()):
        raise SystemExit("dist/current contains existing outputs. Preserve them; no overwrite or cleanup performed.")
    output.mkdir(parents=True, exist_ok=True)
    stage = output / "staging"
    for name, data in entries.items():
        target = stage / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
    package = output / f"{MOD}-{version}-workshop-ready.zip"
    with zipfile.ZipFile(package, "x", zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
        for name, data in sorted(entries.items()):
            meta = zipfile.ZipInfo(name, (1980, 1, 1, 0, 0, 0))
            meta.compress_type = zipfile.ZIP_DEFLATED
            meta.external_attr = 0o100644 << 16
            archive.writestr(meta, data)
    with zipfile.ZipFile(package) as archive:
        assert archive.testzip() is None
        assert len(archive.namelist()) == len(entries) and set(archive.namelist()) == set(entries)
        for name, data in entries.items():
            assert archive.read(name) == data == (stage / name).read_bytes(), name
    content = stage / "Contents"
    assert list((content / "mods").iterdir()) == [content / "mods" / MOD]
    vdf = output / "upload.vdf"
    fields = {"appid": "108600", "publishedfileid": ITEM,
              "contentfolder": content.resolve().as_posix(),
              "previewfile": (stage / "preview.png").resolve().as_posix(),
              "title": "B47ANCE'd Harvest", "description": desc, "changenote": notes}
    # Omit visibility/tags so Steam preserves the existing item's settings.
    vdf.write_text('"workshopitem"\n{\n' + "".join("\t" + quote(k) + " " + quote(v) + "\n" for k, v in fields.items()) + "}\n", encoding="utf-8", newline="\n")
    manifest_path = args.game_root.resolve().parent.parent / "appmanifest_108600.acf"
    manifest_text = manifest_path.read_text(encoding="utf-8")
    build = re.search(r'"buildid"\s*"(\d+)"', manifest_text)
    assert build, "Installed Steam build is unknown"
    hashes = {name: sha(data) for name, data in sorted(entries.items())}
    record = {"version": version, "mod_id": MOD, "workshop_id": ITEM, "appid": "108600",
              "source_commit": git("rev-parse", "HEAD").decode().strip(),
              "hardening_merge_commit": "2a13d4d950b5f552d2b3a5b9eef3f5480af5237f",
              "steam_build": build.group(1), "game_version": "UNKNOWN",
              "target_build": "Build 42", "minimum_game_version": "42.20.3",
              "package": package.name, "package_sha256": sha(package.read_bytes()),
              "vdf_sha256": sha(vdf.read_bytes()), "members_sha256": hashes,
              "validation": {"offline_hosts": "PASS: nine fixtures each on Lua 5.4 and 5.1",
                             "source_and_archive": "PASS", "SP": "NOT TESTED", "G7": "BLOCKED / NOT TESTED", "G8": "BLOCKED"},
              "visibility": "omitted from VDF; preserve existing", "upload_result": "NOT ATTEMPTED"}
    record["preview_export"] = preview
    record["mod_icon"] = artwork["mod_icon"]
    (output / "release-manifest.json").write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8", newline="\n")
    subprocess.run([sys.executable, "scripts/check_versions.py", "--root", ".", "--release", "--json"], cwd=ROOT, check=True)
    print(json.dumps({"package": str(package), "sha256": record["package_sha256"], "source_commit": record["source_commit"], "workshop_id": ITEM}, indent=2))


if __name__ == "__main__":
    main()
