"""Read-only identity, Lua syntax/path and historical preservation checks."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import struct
from lupa.lua54 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / "Contents/mods/B47ANCEDHarvest"


def main(require_local_history=False):
    preservation = json.loads((ROOT / "docs/RENAME_PRESERVATION.json").read_text(encoding="utf-8"))
    artwork = json.loads((ROOT / "docs/ARTWORK.json").read_text(encoding="utf-8"))
    previous_art = artwork["preserved_previous_artwork"]
    icon = artwork["mod_icon"]
    assert icon["original_preservation_key"] == "Contents/mods/farmWorks/42/icon.png"
    assert icon["previous_sha256"] == preservation["protected_sha256"][icon["original_preservation_key"]]
    assert previous_art["original_paths"] == ["preview.png", "Contents/mods/farmWorks/thumbnail.png"]
    assert all(preservation["protected_sha256"][name] == previous_art["sha256"]
               for name in previous_art["original_paths"])
    verified = 0
    omitted = 0
    for original, digest in preservation["protected_sha256"].items():
        current = original
        if current.startswith("Contents/"):
            current = current.replace("Contents/mods/farmWorks/", "Contents/mods/B47ANCEDHarvest/")
        if original in previous_art["original_paths"]:
            current = previous_art["path"]
        if original == icon["original_preservation_key"]:
            current = icon["previous_path"]
        path = ROOT / current
        local_history = current.startswith("dist/") or current == ".steamcmd-last-upload.sha256"
        if not path.exists() and local_history and not require_local_history:
            omitted += 1
            continue
        assert hashlib.sha256(path.read_bytes()).hexdigest() == digest, current
        verified += 1
    assert artwork["applied_files"] == ["Contents/mods/B47ANCEDHarvest/thumbnail.png"]
    for name in artwork["applied_files"]:
        data = (ROOT / name).read_bytes()
        assert hashlib.sha256(data).hexdigest() == artwork["sha256"], name
        assert len(data) == artwork["bytes"] and data[:8] == b"\x89PNG\r\n\x1a\n", name
        assert struct.unpack(">II", data[16:24]) == (artwork["width"], artwork["height"]), name
    preview = artwork["workshop_export"]
    assert preview["path"] == "preview.png" and preview["source"] == artwork["applied_files"][0]
    data = (ROOT / preview["path"]).read_bytes()
    assert hashlib.sha256(data).hexdigest() == preview["sha256"]
    assert len(data) == preview["bytes"] < preview["max_bytes_exclusive"] == 1_000_000
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    assert struct.unpack(">II", data[16:24]) == (preview["width"], preview["height"])
    assert icon["path"] == "Contents/mods/B47ANCEDHarvest/42/icon.png"
    assert icon["source"] == "assets/branding/harvest-icon-source.png"
    for name, digest, width, height in (
            (icon["source"], icon["source_sha256"], icon["source_width"], icon["source_height"]),
            (icon["path"], icon["sha256"], 32, 32)):
        data = (ROOT / name).read_bytes()
        assert hashlib.sha256(data).hexdigest() == digest, name
        assert data[:8] == b"\x89PNG\r\n\x1a\n", name
        assert struct.unpack(">II", data[16:24]) == (width, height), name
        assert data[24:26] == b"\x08\x06", "Icon must be 8-bit RGBA PNG"
    info = dict(line.split("=", 1) for line in (MOD / "42/mod.info").read_text().splitlines() if "=" in line)
    assert info["icon"] == "icon.png" and info["poster"] == "thumbnail.png"
    assert info["name"] == "B47ANCE'd Harvest" and info["id"] == "B47ANCEDHarvest"
    assert info["modversion"] == (ROOT / "VERSION").read_text().strip()
    assert (ROOT / "WORKSHOP_ID.txt").read_text().strip() == "3788591121"
    workshop = (ROOT / "workshop.txt").read_text(encoding="utf-8")
    lines = [line.removeprefix("description=") for line in workshop.splitlines() if line.startswith("description=")]
    assert "\n".join(lines) + "\n" == (ROOT / "WORKSHOP_DESCRIPTION.txt").read_text(encoding="utf-8")
    assert "title=B47ANCE'd Harvest" in workshop and "visibility=public" in workshop
    assert "Mod ID: B47ANCEDHarvest" in workshop
    assert not (ROOT / "Contents/mods/farmWorks").exists()
    lua_root = MOD / "42/media/lua"
    lua = LuaRuntime(unpack_returned_tuples=True)
    syntax = lua.eval("function(s,n)local f,e=load(s,n);assert(f,e)end")
    paths = {p.relative_to(lua_root).as_posix(): p for p in lua_root.rglob("*.lua")}
    assert len({path.casefold() for path in paths}) == len(paths), "Lua path case collision"
    for relative, path in paths.items():
        source = path.read_text(encoding="utf-8")
        syntax(source, relative)
        for name in re.findall(r'require\s*(?:\(\s*)?["\x27]([^"\x27]+)["\x27]', source):
            assert any(f"{realm}/{name}.lua" in paths for realm in ("shared", "client", "server")), (relative, name)
    assert not any(p.suffix.lower() in (".java", ".jar", ".class") for p in MOD.rglob("*") if p.is_file())
    print(f"PASS: identity, Workshop text parity, {len(paths)} Lua syntax/case checks, Lua-only source")
    print(f"PASS: {verified} protected files retain original SHA-256")
    print("PASS: original thumbnail and Workshop PNG export hashes/dimensions/size; previous artwork preserved")
    print("PASS: selected RGBA mod icon source/export hashes; original icon preserved")
    if omitted:
        print(f"NOTE: {omitted} local historical outputs absent from this checkout; not validated")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--require-local-history", action="store_true",
                        help="Require every original local artifact as well as portable source assets")
    main(parser.parse_args().require_local_history)
