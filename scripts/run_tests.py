"""Run the existing Lua host fixtures in isolated Lupa runtimes; never starts PZ."""
from pathlib import Path
from lupa import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
MODS = list((ROOT / "Contents/mods").glob("*/42/mod.info"))
assert len(MODS) == 1, "Expected exactly one authoritative mod.info"
LUA = MODS[0].parent / "media/lua"

CASES = {
    "test_api.lua": ["shared/farmWorks/API.lua"],
    "test_calendar_probe.lua": ["client/farmWorks/CalendarProbe.lua"],
    "test_debug_inspector.lua": ["shared/farmWorks/API.lua", "client/farmWorks/DebugInspector.lua"],
    "test_load_graph.lua": ["server/farmWorks/Load.lua", "client/farmWorks/Load.lua"],
    "test_seasonal_guidance.lua": ["shared/farmWorks/SeasonalGuidance.lua"],
    "test_seed_guidance.lua": ["shared/farmWorks/SeedGuidance.lua"],
    "test_vanilla_seasonal_guidance.lua": [],
    "test_identity.lua": [],
}


def runtime():
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().package.path = ";".join(
        (LUA / realm / "?.lua").as_posix() for realm in ("shared", "client", "server")
    ) + ";" + lua.globals().package.path
    return lua


if __name__ == "__main__":
    for name, arguments in CASES.items():
        lua = runtime()
        lua.globals().arg = lua.table_from([(LUA / item).as_posix() for item in arguments])
        lua.execute((ROOT / "tests" / name).read_text(encoding="utf-8"))
        print("PASS", name, flush=True)
    print(f"PASS: {len(CASES)} offline Lua host fixtures; no PZ runtime evidence")
