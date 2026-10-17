"""Read-only identity, Lua syntax/path and historical preservation checks."""
from pathlib import Path
import argparse
import hashlib
import json
import re
from lupa import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / "Contents/mods/B47ANCEDHarvest"


def main(require_local_history=False):
    preservation = json.loads((ROOT / "docs/RENAME_PRESERVATION.json").read_text(encoding="utf-8"))
    verified = 0
    omitted = 0
    for original, digest in preservation["protected_sha256"].items():
        current = original
        if current.startswith("Contents/"):
            current = current.replace("Contents/mods/farmWorks/", "Contents/mods/B47ANCEDHarvest/")
        path = ROOT / current
        local_history = current.startswith("dist/") or current == ".steamcmd-last-upload.sha256"
        if not path.exists() and local_history and not require_local_history:
            omitted += 1
            continue
        assert hashlib.sha256(path.read_bytes()).hexdigest() == digest, current
        verified += 1
    info = dict(line.split("=", 1) for line in (MOD / "42/mod.info").read_text().splitlines() if "=" in line)
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
    if omitted:
        print(f"NOTE: {omitted} local historical outputs absent from this checkout; not validated")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--require-local-history", action="store_true",
                        help="Require every original local artifact as well as portable source assets")
    main(parser.parse_args().require_local_history)
