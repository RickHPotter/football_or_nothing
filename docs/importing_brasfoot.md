# Importing Brasfoot Packs

Brasfoot team files are serialized Java objects with a `.ban` extension. The importer treats them as an optional, user-provided data source and does not commit imported pack data to the repository.

## Import

```bash
BRASFOOT_PACK_PATH="/media/lovelace/01D8A2DEE1DFF560/REAL BRASFOOT 2026" bin/rails brasfoot:import
```

The master import loads teams first, then club visual assets, then configured national and state leagues. By default it imports every `.cfg` from `conf_ligas_nacionais` and every `.ces` from `conf_estadual`; pass `BRASFOOT_LEAGUE_CONFIGS=BRA.cfg,ING.cfg,RJ.ces` to limit the set, `BRASFOOT_SKIP_ASSETS=true` to skip PNG attachments, or `BRASFOOT_SKIP_LEAGUES=true` to import only teams/assets.

League imports create one domestic league tournament per division, an edition for `BRASFOOT_SEASON_YEAR` (`2026` by default), participations from the planned membership order, and double round-robin fixtures through `LeagueScheduler`. State `.ces` files currently import matching state teams into the first division because the decoded state config does not include a clear team-count field per division.

For a smoke test:

```bash
BRASFOOT_LIMIT=10 bin/rails brasfoot:import
```

To debug one team file:

```bash
bin/rails brasfoot:file["/media/lovelace/01D8A2DEE1DFF560/REAL BRASFOOT 2026/teams/flarj.ban"]
```

To inspect tournament config files and a team's likely tournament fields:

```bash
bin/rails brasfoot:league_config["/media/lovelace/01D8A2DEE1DFF560/REAL BRASFOOT 2026/conf_ligas_nacionais/BRA.cfg"]
bin/rails brasfoot:debug_team["/media/lovelace/01D8A2DEE1DFF560/REAL BRASFOOT 2026/teams/flarj.ban"]
bin/rails brasfoot:plan_memberships["/media/lovelace/01D8A2DEE1DFF560/REAL BRASFOOT 2026/conf_ligas_nacionais/BRA.cfg"]
bin/rails brasfoot:import_league["/media/lovelace/01D8A2DEE1DFF560/REAL BRASFOOT 2026/conf_ligas_nacionais/BRA.cfg"]
bin/rails brasfoot:assets
bin/rails brasfoot:audit
```

PNG files from `teams/escudos`, `teams/escudosMini`, `teams/camisas`, `teams/camisas2`, and `teams/camisas3` are attached to clubs with Active Storage.

The audit task prints summary counts and a bounded list of data-quality issues.
Use `BRASFOOT_AUDIT_LIMIT=50` to show more examples per issue bucket.

The national `.cfg` and state `.ces` files define competition formats. They do not appear to contain readable team names; team-to-division assignment appears to be derived from numeric team metadata or Brasfoot's own sorting rules.

## Current Mapping

- `.ban` team object -> `Club`
- team stadium/city fields -> `Stadium`
- serialized player list -> `Athlete`
- player club membership -> current `AthleteContract`
- filename suffixes such as `_ing`, `_esp`, `_arg`, `_mex`, `_sp`, `_rj`, and compact endings such as `flarj` -> inferred `Country` where known

The pack does not provide data in the same shape as the game database. Ratings and positions are normalized into the current 1-20 athlete attribute model, and all imported pack records use `external_source = "brasfoot_pack"` by default.

Unknown filename suffixes fall back to the synthetic `Brasfoot Pack` country. This keeps imports running while we expand the suffix map.

League config country codes are normalized separately from team filename suffixes. For example, Brasfoot national configs such as `ALE.cfg`, `ING.cfg`, `HOL.cfg`, and `EUA.cfg` are imported under the existing `GER`, `ENG`, `NED`, and `USA` country records. If a config points to a country that has not been created by team import, league import creates a minimal active country record so the master import can continue.

Files with a `.ban` extension but a non-Java-serialization header are skipped by the importer. This has already appeared in real packs, so a single malformed file should not abort the whole import.

## Caveat

Use this for local/private bootstrapping unless the specific pack license allows redistribution. Commit the importer, not imported real-world pack data.
