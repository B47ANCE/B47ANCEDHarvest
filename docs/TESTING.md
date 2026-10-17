# B47ANCE'd Harvest testing

Run from the project root with Python 3 and Lupa:

```powershell
python scripts/check_versions.py --root . --json
python scripts/run_tests.py
python scripts/run_tests.py --lua51
python scripts/check_identity.py
```

In the original development workspace, also run
`python scripts/check_identity.py --require-local-history` to require all local
historical artifacts. Clean Git checkouts report absent ignored outputs without
claiming to validate them; source artwork and metadata remain required.

Each fixture runs in an isolated Lua host. Coverage includes crop providers,
bounded fields, irrigation client rejection/readback, seasonal/seed guidance,
diagnostic probes, production loaders, and new/legacy identity compatibility.
Nine fixtures now include test_hardening.lua with eight regression groups.
The runner explicitly mocks non-client authority and enabled native seasons;
these fixtures are not live engine evidence. --lua51 selects a Lua 5.1 host,
not the game's Kahlua VM.
The formerly documented Run-HostTests.ps1 / Validate-Suite.ps1 scripts are
unavailable in this workspace; the standalone runner replaces those commands.

Historical 0.8.0 coverage remains tied to its original version. Passing those
assertions now is offline evidence only, not native crop-registry, game-clock,
save/load, or multiplayer proof.

## Required runtime checks

Verify the exact installed Build 42 version before testing:
1. Replace farmWorks with B47ANCEDHarvest in enabled-mod lists. Confirm only
   the new identity loads; test existing saves and subscriptions.
2. Compare native crop guidance with the planting menu in best/risk/sow/excluded months.
3. Compare peer dates at midnight, month/year rollover and leap days.
4. Repeat after save/reload, hosted late join and dedicated join/rejoin/restart.
5. Validate custom/malformed crop arrays and explicit map context; missing
   assumptions must fail closed without changing planting.
6. Validate crop-side irrigation authority and supply coupling after an
   evidence-backed waterWorks transaction exists.

Use explicit map geography for the bounded read-only diagnostic:

```lua
B47ANCEDHarvestCalendarBegin("pz.default-map", "north")
B47ANCEDHarvestCalendarObserve()
```

Save, return to the menu, reload, then:

```lua
B47ANCEDHarvestCalendarVerify()
```

Require begin PASS and reload PASS with non-regressed world age. Legacy
farmWorksCalendar* commands remain aliases. Adapt example identifiers to the
map's documented policy and compare dates on every peer. Host tests and UI
comparisons do not prove synchronization. G7 dedicated MP NOT TESTED / BLOCKED;
stable G8 BLOCKED.

## Hardening runtime checklist

- Compare a planted crop with adjacent empty furrows; empty plots must not alter
  crop count, mean water or irrigation demand.
- With PlantGrowingSeasons disabled on the server, advice must be unavailable
  on clients even when a caller supplies seasonsEnabled=true.
- Compare best/sow/risk advice with native definitions and test bounded custom
  windows separately; custom calendar IDs must not use native month windows.
- On the dedicated authority, verify one crop's water change, client update,
  late join and save/restart persistence. Client-side mutation must reject.
- Exercise controlled test providers on disposable fixtures for partial/unknown
  effect reconciliation. Never apply destructive fault tests to player saves or
  interpret false as rollback. Source-water automation remains gated.
