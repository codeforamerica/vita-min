# Rails 8 upgrade plan (GYR1-989)

Status: Phases 0-5 complete (2026-09-03). Rails 8.1.3.1 is the primary boot with load_defaults 8.0; suite at parity. Phase 6 (load_defaults 8.1) and Phase 7 (cleanup) pending
Started from: Rails 7.2.3.2, Ruby 3.4.10, Bundler 2.3.5
Now on: Rails 8.1.3.1 (`Gemfile.lock`), `load_defaults 8.0`
Target: Rails 8.1.3.1

## Summary

Two hard gem blockers, both with fixes already published. No Ruby bump needed
(Rails 8.1 requires >= 3.2; we are on 3.4.10). The dependency resolution has been
verified locally — see "Verified resolutions" below.

Recommended path: **7.2 → 8.0 (gems + defaults) → 8.1 (gems + defaults)**, with the
gem bump and the `load_defaults` bump as separate PRs at each step. Do not go
straight to 8.1: `activerecord-postgis-adapter` pins the Rails minor exactly, so
each minor is a discrete, atomic change anyway, and splitting the framework-defaults
migration across two steps keeps each diff reviewable. This mirrors how the 7.1 and
7.2 upgrades were done in this repo.

## Blockers

| Gem | Current | Constraint | Fix |
| --- | --- | --- | --- |
| `activerecord-postgis-adapter` | 10.0.2 | `activerecord ~> 7.2.0` | 11.0.0 (`~> 8.0.0`) then 11.1.1 (`~> 8.1.0`) |
| `rails-i18n` | 7.0.10 | `railties >= 6.0.0, < 8` | 8.1.0 (`railties >= 8.0.0, < 9`) |

`activerecord-postgis-adapter` pins to one Rails minor at a time, and
`rgeo-activerecord` follows it (`8.0.0` → AR 8.0, `8.1.0` → `activerecord >= 8.1, < 8.2`).
We use `adapter: postgis` in every environment (`config/database.yml`), so this is
on the critical path and cannot be deferred.

Everything else in the Gemfile already permits Rails 8: `devise` 5.0.4,
`rspec-rails` 8.0.4, `data_migrate` 11.3.0, `paper_trail` 17.0, `statesman` 11.0,
`strong_migrations` 1.6.4, `shakapacker` 9.7.0, `delayed_job_active_record` 4.1.11
(`activerecord >= 3.0, < 9.0`), `pundit`, `flipper`, `sass-rails`/`sassc-rails`,
`sprockets-rails` 3.5.2.

## Verified resolutions

Resolved against rubygems from the real Gemfile in a scratch directory. A **targeted**
update of just the Rails family + postgis + rails-i18n moves 25–26 gems:

Rails 8.0 step (25 changed, 0 added, 0 removed):
`rails`/`activesupport`/`activerecord`/`actionpack`/`actionview`/`actionmailer`/
`activejob`/`activemodel`/`activestorage`/`actioncable`/`actionmailbox`/`actiontext`/
`railties` 7.2.3.2 → 8.0.5.1, `activerecord-postgis-adapter` 10.0.2 → 11.0.0,
`rails-i18n` 7.0.10 → 8.1.0, plus transitive: `erb`, `io-console`, `mail`, `minitest`,
`net-imap`, `net-protocol`, `rack` 3.2.6 → 3.2.7, `rbs`, `reline`, `zeitwerk`.

Rails 8.1 step (26 changed, 1 added): same set at 8.1.3.1, `activerecord-postgis-adapter`
11.0.0 → 11.1.1, `rgeo-activerecord` 8.0.0 → 8.1.0, and `action_text-trix` added
(Trix was extracted from actiontext in 8.1).

Bundler 2.3.5 resolves both without needing a bundler bump. This matters because
`Dockerfile:45` installs bundler from the lockfile's `BUNDLED WITH` — do not let a
stray `bundle` run under a newer bundler rewrite it as a side effect of this work.

### Do not run a bare `bundle update`

A full re-resolve moves **138 gems** and silently crosses major versions on things
that will break the suite or production behavior:

`minitest` 5.27 → 6.0, `shoulda-matchers` 5.3 → 8.0, `rubyzip` 2.3 → 3.5,
`phony` 2.20 → 3.0 (phone formatting, used throughout), `statesman` 11 → 13
(state machines are core here), `strong_migrations` 1.6 → 2.8, `redis` 5 → 6,
`sentry-*` 5.13 → 6.7, `openssl` 3.3 → 4.0, `holidays` 8.8 → 11.5,
`mixpanel-ruby` 2.3 → 3.3, `zxcvbn-ruby` 1.2 → 2.0, `simplecov` 0.22 → 1.1,
`connection_pool` 2.5 → 3.0, `ordinalize_full` 3 → 4, `rack-mini-profiler` 4 → 5,
`selenium-webdriver` 4.15 → 4.48. Each of those deserves its own PR, not this one.

Note `minitest` 5.27 → 6.0.6 gets pulled in even by the targeted update, purely
because nothing in the tree constrains it (`railties` and `activesupport` both say
`minitest >= 5.1`). Pin it — `gem 'minitest', '~> 5.27'` — to hold it out of this
change, and drop the pin in a follow-up.

## Framework defaults

Confirmed against `rails/rails` `8-0-stable` and `8-1-stable`
`railties/lib/rails/application/configuration.rb`.

`load_defaults 8.0` sets exactly:

- `action_dispatch.strict_freshness = true` — with both `If-Modified-Since` and
  `If-None-Match` present, only `If-None-Match` is considered (RFC 7232 §6).
- `Regexp.timeout ||= 1`

`load_defaults 8.1` additionally sets:

- `self.yjit = !Rails.env.local?` — **YJIT on in production/staging/demo/heroku.**
  Perf win, but it is a runtime change; watch memory on first deploy.
- `action_controller.escape_json_responses = false`
- `action_controller.action_on_path_relative_redirect = :raise`
- `active_record.raise_on_missing_required_finder_order_columns = true`
- `active_support.escape_js_separators_in_json = false`
- `action_view.render_tracker = :ruby`
- `action_view.remove_hidden_field_autocomplete = true`

Follow the existing pattern in `config/application.rb`: inline the deltas we depart
from inside `BEGIN/END additions for Rails 8.x defaults migration` banners rather than
adding `config/initializers/new_framework_defaults_8_*.rb` files. Carry forward the
existing deliberate departures (`hash_digest_class = SHA1`,
`button_to_generates_button_tag = false`, `precompile_filter_parameters = false`,
`add_autoload_paths_to_load_path = true`, `active_storage.web_image_content_types`,
`default_headers` with `X-Download-Options`).

### Specific risks in this codebase

**`Regexp.timeout = 1` and `device_detector`.** Investigated and cleared in Phase 0 —
see "Regexp.timeout: measured" below. Short version: 194,640 adversarial matches across
all 24,330 of the gem's regexes produced zero timeouts and a 6.5 ms worst case, so the
1-second budget has ~150× headroom. Adopt it, staged (`5` first, then `1`).

**`to_time` semantics change on 8.1, not opt-in.** In Rails 8.1
`config.active_support.to_time_preserves_timezone` is deprecated and the
`preserve_timezone` mattr is gone from
`active_support/core_ext/date_and_time/compatibility.rb` — `to_time` always preserves
the zone, regardless of `load_defaults`. We have three call sites
(`app/models/efile_submission.rb:245`, `app/services/mixpanel_service.rb:401,408`) and
all three are subtractions between two times, where zone-vs-offset does not change the
result. Verify, then move on. The 8.0 step is where we can adopt `:zone` deliberately.

**`action_on_path_relative_redirect = :raise`.** Grep found no bare relative
`redirect_to "foo"` in `app/`. Low risk, but this raises rather than logs, so re-grep
after any rebase.

**`remove_hidden_field_autocomplete = true`.** Any spec that asserts on full rendered
form HTML will see `autocomplete="off"` disappear from hidden inputs generated by
`form_tag`/`token_tag`/`method_tag`/`button_to`. Audit `spec/helpers/`,
`spec/test_views/`, and the Percy snapshots.

**`raise_on_missing_required_finder_order_columns = true`.** Only raises for models
with no `implicit_order_column`, no `query_constraints`, and no primary key. Check the
`Analytics::` models backed by `db/create_analytics_views.sql` and
`app/models/data_science.rb`, which may be primary-key-less views.

**`schema.rb` column sorting (8.1).** Rails 8.1 alphabetizes columns in `schema.rb`.
We already do this via `fix-db-schema-conflicts`
(`config/initializers/fix_db_schema_conflicts.rb`), so the dump should be close to a
no-op — verify, and consider dropping the gem afterward if Rails now covers
everything we rely on it for. The header line will change from
`ActiveRecord::Schema[7.2]` to `[8.0]` / `[8.1]`.

**`ActiveRecord::Base.connection`.** ~20 call sites (`app/models/efile_submission.rb`,
`app/jobs/remove_unconsented_clients_job.rb`, `app/services/base_service.rb`,
`app/services/efile/*`, `lib/tasks/*.rake`). Fine on 8.x defaults
(`permanent_connection_checkout` defaults to `:allowed`). Do **not** set that config
to `:deprecated` or `:disallowed` as part of this work.

## Dead weight to drop first

- **`scenic`** — no `db/views/` directory, no `create_view`/`update_view` anywhere.
  The only "Scenic" match in the repo is a South Dakota town in `db/zip_codes.yml`.
  Analytics views are managed by raw SQL in `lib/tasks/analytics.rake`. Removing it
  takes a gem off the compatibility matrix for free.
- **`spring` / `spring-commands-rspec`** — effectively unmaintained and not part of
  modern Rails. Optional, but one fewer boot-path variable.

## Testing strategy given the local environment

Some specs cannot pass on this machine (no credentials for Percy, AWS/Bedrock,
Mailgun, Twilio, Transifex; `pdftk`/`gyr_efiler`/`pycall` may be unavailable). The
suite has 923 spec files and CI runs `parallel_rspec -n 12` with a retry pass
(`.circleci/config.yml:151`). CI is the gate, not this laptop.

So: **do not chase green locally — chase "no new failures versus a recorded 7.2
baseline."**

1. On `main` (Rails 7.2), before touching anything, record a baseline:

   ```
   bundle exec parallel_rspec -n 8
   ```

   Keep `tmp/rspec-parallel-test-results/*.xml`. Extract the failing example IDs into
   a checked-in-nowhere scratch file, e.g. `tmp/baseline-7.2-failures.txt`.

2. After each upgrade step, re-run the same command and diff the failure sets. Only
   failures **not** in the baseline are yours. `--only-failures` (already used in CI)
   plus RSpec's persistence file (`spec/examples.txt`) makes this cheap to iterate on.

3. Push early and rely on CI for the environment-dependent specs (Percy, efile
   schemas, screenshots). The `run_ruby_tests` job is the real signal.

4. Flip `config.active_support.deprecation` to `:raise` in `config/environments/test.rb`
   for the duration of each step (it is `:log` today, line 74) so that Rails 8
   deprecations fail loudly instead of scrolling past in a 12-way parallel run. Revert
   before merge.

## Step-by-step

### Phase 0 — prep — **DONE** (2026-09-01, on `GYR1-989-upgrade-to-rails-8`)

1. ✅ `scenic` dropped. Verified unused: no `db/views/`, no `create_view`/`update_view`/
   `drop_view` in `db/migrate` or app code, nothing else in the lock depends on it. The
   `analytics:create_views` rake task is raw SQL and unrelated. Lock diff was exactly 4
   lines in each of `Gemfile.lock` and `Gemfile_next.lock`; `BUNDLED WITH` (2.3.5)
   preserved. App boots, `Scenic` undefined, `spec/tasks/analytics_spec.rb` 6/0.
2. ✅ Baseline recorded — see "Rails 7.2 baseline" below.
3. ✅ `spring` — **deferred to Phase 7.** Spring 4.1.2 has no Rails constraint and did
   not move in either targeted 8.0/8.1 resolution, so it is not a blocker. Its only hook
   is `bin/rspec` → `bin/spring`; `bin/rails`, `bin/rake` and CI do not use it. Removing
   it changes every engineer's local single-spec workflow — an unrelated DX change that
   would only widen the blast radius of a revert.
4. ✅ `Regexp.timeout` — **adopt it, staged.** See "Regexp.timeout: measured" below.

### Rails 7.2 baseline

Recorded at `f44939a63`, Rails 7.2.3.2, `parallel_rspec -n 8` on 10 cores / 16 GB.

```
9,880 examples   155 failures   220 pending   14:49 wall
```

Artifacts in `tmp/baseline-7.2/` (gitignored): `run.log`, `COMMIT`,
`failed-current.txt` (the 155 failing example IDs), `examples-prior-run.txt`.

**The failure set is exactly reproducible.** An independent run that finished two
minutes before the baseline produced the identical 155 example IDs — zero drift in
either direction. Any new failure after the upgrade is therefore attributable to the
upgrade, not flakiness.

**~151 of the 155 share a single root cause** — `app/lib/schema_file_loader.rb:38`:

```
Aws::S3::Client.new(region: REGION)
  → PUT http://169.254.169.254/latest/api/token   (EC2 instance metadata)
  → WebMock::NetConnectNotAllowedError
```

`SchemaFileLoader.load_file` checks `vendor/<dir>/` first and only falls back to S3 if
absent. `vendor/irs/` contains just `.keep` and `vendor/us_states/` is empty (both
gitignored), so every efile schema load reaches for the
`vita-min-irs-e-file-schema-prod` bucket and dies without AWS credentials. CI avoids
this entirely by running `setup:download_efile_schemas setup:unzip_efile_schemas`
(`.circleci/config.yml:74`).

Ten zips are needed: `efile1040x_{2020v5.1,2021v5.2,2022v5.3,2023v5.0}.zip` →
`vendor/irs/`, and `AZIndividual2024v2.1`, `ID_MeF2024V0.1`, `MDIndividual2024v1.0`,
`NCIndividual2024v1.0`, `NJIndividual2024V0.1`, `NYSIndividual2023V4.0` →
`vendor/us_states/`. Obtainable from S3 with credentials, or manually from the Drive
folder named at `lib/tasks/setup.rake:25`.

**Decision (2026-09-01): proceed with the 155-failure baseline; do not populate the
schemas locally.** Consequence to work around deliberately: local runs are blind to
Rails 8 regressions in the efile XML submission pipeline (Nokogiri tree building,
`rubyzip`, ActiveRecord) — the most business-critical and among the most
Rails-version-sensitive code in the app. CI does download the schemas
(`.circleci/config.yml:74`), so final safety is unaffected; what we lose is local
iteration speed on precisely the riskiest 151 specs.

Mitigations, given that choice:

- Treat the `DEPENDENCIES_NEXT=1` CI job as the real Phase 2 gate, not local runs. Push
  early and often rather than batching fixes locally.
- Expect a step change in CI failures the first time the efile specs actually execute
  against Rails 8. Budget for it instead of reading a green local run as "done".
- If Phase 2 stalls on efile-related CI failures that are hard to iterate on remotely,
  revisit this decision — one set of credentials converts a slow remote loop into a fast
  local one.

The remaining 4 failures are unrelated to the upgrade and pre-existing on this commit:

| Spec | Symptom |
| --- | --- |
| `spec/features/hub/take_action_spec.rb` | expected `/en/hub/clients/107`, got `.../edit_take_action` |
| `spec/features/hub/clients_searching_sorting_and_filtering_spec.rb` | expected 1 client row, got 4 |
| `spec/features/web_intake/menu_spec.rb` | mobile menu "Login" link visible when it should not be |
| `spec/features/web_intake/new_joint_filers_spec.rb` | tax years `[]`, expected `[2022, 2023, 2024]` |

⚠️ **The baseline has a shelf life.** `new_joint_filers_spec.rb` derives years from
`MultiTenantService#current_tax_year`, which depends on wall-clock date against
`config.tax_year_filing_seasons` and the intake-window constants in
`config/application.rb`. Today (2026-09-01) sits after `tax_deadline` (2026-04-15) and
before `end_of_intake` (2026-10-01). Crossing 2026-10-01 will change behavior in this
and possibly other specs. If Phase 2 slips past that date, **re-record the baseline**
rather than comparing across the boundary.

### Regexp.timeout: measured

`load_defaults 8.0` sets `Regexp.timeout ||= 1`. The concern was `device_detector`,
whose regexes run on user-controlled `User-Agent` on every request
(`app/controllers/application_controller.rb:254`, `app/services/mixpanel_service.rb:270`).

Probe: all 12,165 regex sources the gem ships, compiled through both of the gem's own
wrapper prefixes (`device_detector.rb:240`, `parser.rb:88`) = 24,330 regexes, matched
against 8 adversarial user agents (4 KB `a` runs, 2000× `x;`, 2000-deep nested parens,
long version-token runs, realistic UA + 3 KB tail):

```
194,640 matches in 2.05s total
Regexp::TimeoutError count: 0
worst single match: 6.5 ms
```

A 1-second budget is ~150× the worst observed case, and that was measured while 8 rspec
workers competed for CPU. Global exposure elsewhere is negligible: only 9
`scan`/`gsub`/`match`/`split` regex call sites across `app/services`, `app/models` and
`lib` combined, none long, none applied to file contents or downloaded blobs.

**Decision: adopt `Regexp.timeout`, but stage it** — ship `5` on the first Rails 8.0
deploy, watch Sentry for one release, then tighten to `1`. Cheap insurance against a
slow regex inside a gem that only production traffic shapes exercise.

Related: `config/initializers/warning.rb` suppresses `device_detector` "nested repeat
operator" warnings that **no longer occur** — compiling all 12,165 sources under
`ruby -w` on device_detector 1.0.7 / Ruby 3.4 emits zero such warnings. The upstream
issue it cites (podigee/device_detector#90) appears resolved. Dead code, harmless,
candidate for deletion in Phase 7.

### Phase 1 — activate bootboot for dual-boot — DONE except CI

`bootboot` 0.2.2 **is** installed as a Bundler plugin (`.bundle/plugin/`), and
`Gemfile_next.lock` exists — but the harness has never resolved a different dependency
set. `Gemfile_next.lock` pins the same Rails 7.2.3.1 as the primary lock, and there is
no dual-boot job in `.circleci/config.yml`.

**Root cause — the two halves are keyed to different environment variables.** This is
the first thing to fix; without it every other step here silently no-ops:

- `Bootboot.env_next` is `Bundler.settings["bootboot_env_prefix"] || "DEPENDENCIES"`
  plus `"_NEXT"` → **`DEPENDENCIES_NEXT`**. No `bootboot_env_prefix` is configured
  (there is no `.bundle/config` in the repo).
- This repo's `gemn` helper in `Gemfile` branches on **`ENV['NEXT']`**.

So when bootboot regenerates `Gemfile_next.lock` it sets `DEPENDENCIES_NEXT=1`, the
`gemn` helper does not see `NEXT`, and the next lockfile gets resolved with the
*current* versions — a byte-for-byte duplicate. Fix by pointing `gemn` at
`ENV['DEPENDENCIES_NEXT']` (bootboot's convention).

Two further mechanics worth knowing, both verified:

- bootboot's auto-sync hooks `after-install-all` only. `bundle lock` never updates
  `Gemfile_next.lock`; **only `bundle install` does.**
- Its `nothing_changed?` guard compares against the lock captured in
  `before-install-all`. If you run `bundle lock` first and then `bundle install`, the
  install sees no change and **skips the sync**. Change the `Gemfile` and go straight
  to `bundle install`.

Three separate things were missing, all required; fixing only some leaves the harness
silently inert:

1. ✅ `gemn` repointed from `ENV['NEXT']` to `ENV['DEPENDENCIES_NEXT']`, and its latent
   double-declaration bug fixed (with `next_version: nil` it called `gem` twice — never
   fired, because `gemn` had no callers). It now takes `*versions` so multi-part
   constraints like `('~> 10.0', '>= 10.0.2')` survive.
2. ✅ `Plugin.send(:load_plugin, 'bootboot')` added. The `plugin` directive only
   declares/installs bootboot; without an explicit load its `Bundler::Dsl` patch does
   not exist while the Gemfile is being evaluated.
3. ✅ `enable_dual_booting` added, guarded on `DEPENDENCIES_NEXT`. Without it bootboot
   never patches `Bundler::Definition`, so `DEPENDENCIES_NEXT=1 bundle install`
   resolves the next Gemfile against the **primary** lockfile and dies with a version
   conflict.

Gems declared through `gemn`:

```ruby
gemn 'rails', '~> 7.2.3.1', next_version: '~> 8.0.5'
gemn 'activerecord-postgis-adapter', '~> 10.0', '>= 10.0.2', next_version: '~> 11.0.0'
```

`rails-i18n` deliberately does **not** need a `gemn` entry — it is unconstrained in the
Gemfile, so bundler picks 7.0.10 against railties 7.2 and 8.1.0 against railties 8.0 on
its own. Verified in both lockfiles.

`gem 'minitest', '~> 5.27'` added to hold minitest out of the upgrade (nothing requires
6; bundler was just taking the newest). No-op for the primary boot. Drop in Phase 7.

Result — the harness resolves two genuinely different sets for the first time:

```
Gemfile.lock       rails (7.2.3.2)   postgis 10.0.2   minitest 5.27.0
Gemfile_next.lock  rails (8.0.5.1)   postgis 11.0.0   minitest 5.27.0
```

Primary lock diff is one line (the minitest DEPENDENCIES entry); next lock moves 28
gems, 0 added, 0 removed.

**Remaining, deliberately not done — the CircleCI job.** Add a job cloning
`run_ruby_tests` with `DEPENDENCIES_NEXT=1` in the environment, non-blocking until
green. Reuse `rails_executor` and the existing postgres+postgis image, and keep the
`setup:download_efile_schemas` step — that job is where the 151 efile specs actually
get exercised, which matters more than usual given the Phase 0 decision not to run them
locally.

#### Note on regenerating `Gemfile_next.lock`

bootboot's auto-sync fires on `after-install-all` and bails via `nothing_changed?` if
`bundle install` did not itself change the primary lockfile. When the next lock needs
updating but the primary one is unchanged (the normal case during this migration),
`bundle install` will **not** sync it. Drive bootboot's `update!` path directly:

```ruby
ENV["DEPENDENCIES_NEXT"] = "1"
ENV["BOOTBOOT_UPDATING_ALTERNATE_LOCKFILE"] = "1"
definition = Bundler::Definition.build(gemfile, next_lock, { gems: UNLOCK })
definition.resolve_remotely!
definition.lock(next_lock)
```

Passing an explicit `{ gems: [...] }` unlock list keeps the diff targeted instead of
re-resolving all 300+ gems. Always confirm `Gemfile.lock` is untouched afterward.

### Phase 2 — status: Rails 8.0 at parity with the baseline

Full suite on the next boot, versus the Rails 7.2 baseline:

| | examples | failures | pending |
| --- | --- | --- | --- |
| baseline (7.2) | 9,880 | 155 | 220 |
| Rails 8.0 | 9,880 | 157 | 220 |

Five example IDs failed on 8.0 that were not in the baseline, and three baseline
failures passed. **None of the five is a Rails 8 regression:**

- `bulk_actions_spec`, `filtered_clients_bulk_action_spec`, `new_joint_filers_spec`,
  `clients_searching_sorting_and_filtering_spec` — all pass in isolation on *both*
  boots. Parallel-execution flakes / order dependence.
- `take_action_spec` — fails on both boots with a byte-identical failure set and
  messages. Pre-existing, and internally inconsistent: `:16` expects to remain on
  `/hub/clients/:id` while `:42` expects `/hub/clients/:id/edit_take_action`.

Note the baseline's own caveat now has evidence behind it: the failing *example IDs*
drift between parallel runs within these feature-spec files even though the totals are
stable. Compare at file granularity for feature specs, not example ID.

Three Rails 8 changes were fixed to get here (commits `b3a3ab7dc`, `61d70543e`):

1. `enum` keyword form removed — 572 sites, see below.
2. Route URL helpers are now defined lazily, so `alias next_path
   portal_overview_documents_path` raised `NameError` at class-body evaluation and took
   out a whole parallel worker (~1,100 examples never ran). Only route-helper alias in
   `app/`.
3. `form_with` raises on a nil `:model`. Three controllers (`IncomeReview`,
   `TermsAndConditions`, `LandingPage`) override `#edit` without `super`, so `@form` is
   never set. Fixed with `@form || false`, after verifying on 7.2 that `model: nil` and
   `model: false` emit byte-identical HTML.

⚠️ **Known blind spot.** The ~151 efile submission-builder specs still fail for the
Phase 0 S3 reason and have therefore *never executed against Rails 8*. Parity above
excludes them entirely. They are the most Rails-version-sensitive code in the app
(Nokogiri tree building, rubyzip, ActiveRecord), and per the Phase 0 decision their
first real Rails 8 exercise happens on a deployed environment. Treat "Phase 2 complete"
as provisional until then.

#### Latent bug found, deliberately not fixed

The income review form's `device_id` hidden field renders **unscoped** (`name="device_id"`)
because `@form` is nil, but `update_for_device_id_collection` reads
`form_params["device_id"]`, which looks under `params["state_file_income_review_form"]`.
So that read never sees the field. Pre-existing on 7.2 — not caused by the upgrade, and
fixing it (by having the controller set `@form`) would change form field naming, which
does not belong in an upgrade PR. Worth its own ticket.

### Phase 2 — first finding: `enum` keyword form removed

The next boot gets as far as eager-loading models and then dies:

```
activerecord-8.0.5.1/lib/active_record/enum.rb:217:in 'enum':
  wrong number of arguments (given 0, expected 1..2) (ArgumentError)
  from app/models/application_record.rb:10:in 'ApplicationRecord.enum'
```

Rails 8.0 removed the keyword form. Its signature is now
`enum(name, values = nil, **options)`, and `assert_valid_enum_options` raises
`ArgumentError` on `_prefix`, `_suffix`, `_scopes`, `_default`, `_instance_methods`.

Scope: **~512 enum declarations across 46 files in `app/models`**, essentially all of
them the keyword form, the large majority carrying `_prefix:` (2 use `_suffix:`; no
`_default`/`_scopes`). Plus the `ApplicationRecord.enum` wrapper
(`app/models/application_record.rb:9`), whose `def self.enum(**enums)` signature has to
change.

```ruby
# before
enum service_type: { online_intake: 0, drop_off: 1 }, _prefix: :service_type
# after
enum :service_type, { online_intake: 0, drop_off: 1 }, prefix: :service_type
```

**This converts cleanly with no version guards.** Rails 7.2's
`enum(name = nil, values = nil, **options)` routes the positional form to the same
`_enum` that accepts `prefix:`/`suffix:`, so converted code is identical in behavior on
both boots. Mechanical and scriptable, but it is a large diff — land it as its own PR,
separate from the rest of Phase 2, and review it by sampling rather than line by line.

### Phase 2 — make the code work on Rails 8.0 (iterate on the NEXT branch)

Keep `config.load_defaults 7.2` throughout this phase. Only fix genuine
incompatibilities. Where behavior must differ between 7.2 and 8.0, guard on
`Rails::VERSION::MAJOR >= 8` so both boots stay green.

1. `DEPENDENCIES_NEXT=1 bundle exec parallel_rspec -n 8`; diff against baseline.
2. Work the failures. Expect the bulk to be in `spec/models`,
   `spec/state_machines` (statesman + AR internals), `spec/db`, and anything asserting
   on generated HTML.
3. `DEPENDENCIES_NEXT=1 bundle exec rake db:drop db:create db:schema:load` — confirm the postgis
   adapter 11 loads the schema and `enable_extension "postgis"` still round-trips.
4. `DEPENDENCIES_NEXT=1 bundle exec rake assets:precompile` — sprockets 4 + shakapacker 9 + sassc.
5. `DEPENDENCIES_NEXT=1 bundle exec annotaterb models --frozen` — CI enforces this
   (`.circleci/config.yml:136`); annotations may shift.
6. `DEPENDENCIES_NEXT=1 bundle exec rake db:migrate` from scratch — `strong_migrations` 1.6 and
   `data_migrate` 11 against AR 8.0.
7. Grep `log/test.log` for `DEPRECATION WARNING` and clear them all.
8. Get the `DEPENDENCIES_NEXT=1` CI job green. Make it blocking.

### Phase 3 — cut over to Rails 8.0 — DONE (2026-09-02)

```
Gemfile.lock       rails 8.0.5.1  postgis 11.0.0  rgeo-ar 8.0.0   ← now the deploying boot
Gemfile_next.lock  rails 8.1.3.1  postgis 11.1.1  rgeo-ar 8.1.0   ← harness moved up to 8.1
```

Both boot. `load_defaults` deliberately still `7.2` — that is Phase 4.

Primary lock diff: **24 gems changed, 0 added, 0 removed**, `BUNDLED WITH` still 2.3.5.
Matches the Phase 0 prediction of 25; the difference is `minitest`, held by its pin.

`db/schema.rb` is deliberately untouched and still stamped `ActiveRecord::Schema[7.2]`.
Rails 8 reads that fine. Note the asymmetry, verified: **Rails 7.2 cannot load a schema
stamped `[8.0]`** (`ArgumentError: Unknown migration version "8.0"`), while Rails 8.0
reads `[7.2]` happily. The stamp flips the first time `db:migrate` runs on this branch,
because migrate re-dumps the schema — so land that when the migration queue is quiet, as
it will conflict with any in-flight migration PR.

Deviation from the original step 1 below: it said to *collapse* the `gemn` indirection,
but step 3 also wanted `Gemfile_next.lock` pointed at 8.1 — collapsing removes the
mechanism step 3 needs. Instead both sides were shifted up one minor, keeping the
harness:

```ruby
gemn 'rails', '~> 8.0.5', next_version: '~> 8.1.3'
gemn 'activerecord-postgis-adapter', '~> 11.0.0', next_version: '~> 11.1'
```

#### CI: the dual-boot job is no longer needed

`run_ruby_tests` has **no branch filter**, so it runs on every branch. Now that
`Gemfile.lock` is Rails 8.0, that existing job *is* the Rails 8 job — full suite at
12-way parallelism with the efile schemas, pdftk and webdriver that a dev laptop lacks.
The separate `DEPENDENCIES_NEXT=1` job was only ever needed to get Rails 8 CI coverage
*before* the cutover.

Pushing a feature branch carries no deploy risk: all three `deploy_to_aptible--*` jobs
are branch-filtered to `main`/`staging`/`release`. Tests do **not** run on deploy —
`.aptible.yml` `before_release` runs only
`rake analytics:drop_views db:migrate analytics:create_views`. CI is the gate, and it is
now a blocking gate for deploys.

Because CI is green on `main`, the CI baseline is *green* — far cleaner than the local
155-failure baseline. Any red on the branch is unambiguous Rails 8 signal.

#### First 8.1 finding (Phase 5 preview, not a blocker)

The 8.1 next boot warns:

```
DEPRECATION WARNING: ActiveSupport::Configurable is deprecated without replacement,
and will be removed in Rails 8.2.
```

Not our code — two gems: `data_migrate` (`lib/data_migrate/config.rb:2`) and
`omniauth-rails_csrf_protection` (`lib/omniauth/rails_csrf_protection/token_verifier.rb:16`).
Deprecated in 8.1, **removed in 8.2**, so it does not block 8.1; it blocks 8.2 and the
fix is upstream gem bumps. `omniauth-rails_csrf_protection` 1.0.2 and 2.0.x exist and
our `~> 1.0` constraint permits 1.0.2. `data_migrate` has nothing newer than 11.3.1.

Watch for this reaching Sentry once 8.1 deploys —
`config/environments/shared_deployment_config.rb` sets
`active_support.deprecation = :notify`.

#### Original steps, for reference

1. ~~Collapse the `gemn` indirection~~ — see deviation above.
2. Regenerate the primary lock with a **targeted** update, not `bundle update`:

   ```
   bundle lock --update rails railties activesupport activerecord actionpack \
     actionview actionmailer activejob activemodel activestorage actioncable \
     actionmailbox actiontext activerecord-postgis-adapter rgeo-activerecord rails-i18n
   ```

   Expect the 25-gem diff described above. Review the lock diff gem by gem.
3. Point `Gemfile_next.lock` at 8.1 so bootboot keeps earning its keep.
4. Deploy to demo/staging first. Watch Sentry
   (`config/environments/shared_deployment_config.rb` sets
   `active_support.deprecation = :notify`) and Datadog for regressions in request
   latency and delayed_job throughput.

### Phase 4 — `load_defaults 8.0` — DONE (2026-09-02)

Touches `config/application.rb` only: `load_defaults 7.2` → `8.0`, plus an 8.0 banner
block in the same style as the 7.1 and 7.2 ones.

`load_defaults 8.0` sets exactly two things (verified in
`railties/lib/rails/application/configuration.rb`, *not* the generator template — the
template also lists `to_time_preserves_timezone`, which `load_defaults` does not
actually set at 8.0):

- **`action_dispatch.strict_freshness = true`** — accepted as-is. Only matters when a
  request carries both `If-Modified-Since` and `If-None-Match`, and we use no
  conditional GET anywhere: zero hits for `fresh_when`, `stale?`, `etag:` or
  `last_modified:` in `app/` or `lib/`. Effectively a no-op.
- **`Regexp.timeout ||= 1`** — adopted but **set to 5**, staged. See "Regexp.timeout:
  measured". The measurement gives ~150x headroom, but the setting is process-global
  (every regex in every gem) and cannot cover a slow regex only production traffic
  shapes reach. Tighten to 1, or delete the line to inherit the default, after one
  release with no `Regexp::TimeoutError` in Sentry.

Verified live on the 8.0 boot: `loaded_config_version` 8.0, `strict_freshness` true,
`Regexp.timeout` 5.0, and all five carried-forward departures intact. Note
`config.action_view[:button_to_generates_button_tag]` reads back `nil` because the
railtie deletes the key after applying it — the applied value on
`ActionView::Helpers::UrlHelper` is still `false`, and `button_to` renders `<input>`
rather than `<button>`, confirmed end to end.

Full suite: **9,880 examples / 154 failures / 220 pending**, no load errors.

| | failures |
| --- | --- |
| baseline 7.2 | 155 |
| Phase 3 (8.0 gems, 7.2 defaults) | 156 |
| Phase 4 (8.0 gems, 8.0 defaults) | 154 |

**Zero new failures versus Phase 3** — `load_defaults 8.0` introduced nothing. The two
IDs that differ from the 7.2 baseline are both in already-identified flaky feature
specs (`filtered_clients_bulk_action_spec`, `new_joint_filers_spec`). No
`Regexp::TimeoutError` anywhere in the run.

⚠️ **The suite cannot validate the one risky item here.** `Regexp.timeout`'s failure
mode is a `Regexp::TimeoutError` raised from arbitrary code under real traffic shapes.
Watch Sentry on the demo/staging deploy, particularly around
`ApplicationController#user_agent` (`app/controllers/application_controller.rb:254`) and
`MixpanelService` (`app/services/mixpanel_service.rb:270`), which run `DeviceDetector`
on the user-controlled `User-Agent`.

Ship this separately from Phase 3 so a defaults revert does not give back the gem
upgrade.

### Phase 5 — Rails 8.1 — DONE (2026-09-03), including the primary cutover

Suite on the 8.1 next boot: **9,880 examples / 154 failures / 220 pending** — the same
failure count as Phase 4 on 8.0. First run before fixes was 160.

| | failures |
| --- | --- |
| baseline 7.2 | 155 |
| Phase 4 (8.0 + defaults) | 154 |
| Phase 5 first run (8.1) | 160 |
| **Phase 5 after fixes (8.1)** | **154** |

Three real 8.1 changes, from 8 new failures across 6 files:

**1. `head` now raises on a double render — a real production bug, not just specs.**
Rails 8.1 adds one line to `action_controller/metal/head.rb`:
`raise ::AbstractController::DoubleRenderError if response_body`. Our
`InvalidCrossOriginRequest` handler tripped it, because Rails raises that from
`verify_same_origin_request`, an **after_action** — the action has already rendered.
Any action that renders and then fails the same-origin check would hit this in
production.

Note the fix that does *not* work: `self.response_body = nil`.
`ActionController::Metal#response_body=` calls `response.reset_body!` without clearing
the `@_response_body` reader that `head` checks, and `metal.rb` is byte-identical
between 8.0 and 8.1 — so that was never viable in either version. Rails has no public
API for replacing an already-rendered response, so the handler now sets
`response.reset_body!` and `response.status = 422` directly and skips `head`.

**2. `nil` controller-spec params no longer coerce to `""` — test-harness only.**

| `params: { field: nil }` | value seen in controller |
| --- | --- |
| Rails 8.0 | `""` |
| Rails 8.1 | `nil` |

Production is unaffected: real HTTP sends `field=` for an empty input, which parses to
`""` on both versions (verified). Six spec params in `client_logins`, `intake_logins`
and `twilio_webhooks` were relying on the old coercion; they now pass `""` explicitly,
which also models real form submissions more accurately.

Aside, unrelated to the upgrade: `twilio_webhooks` writes `error_code` straight to a DB
column, so `""` vs `nil` there is empty-string vs NULL in stored data. Worth its own
look.

**3. `spec/lib/pdf_filler/id39r_pdf_spec.rb` is a local pdftk flake, not 8.1.** Passes
3/3 in isolation on 8.1; under 8 parallel workers a *different example* fails each run
with a *different* error (`expected "0" got nil`, then `IOError` from
`PdfForms.new.get_fields`). That is pdftk resource contention via the `pdf-forms` gem,
not a Rails API. CI installs pdftk-java properly, so CI is where this gets a real
answer.

#### Already-resolved items, re-verified

- **`to_time`** — switched to `:zone` back in **Phase 4**, not 8.1. `load_defaults 8.0`
  sets it explicitly; 8.1 hardcodes the same behavior (hence the config reading `nil`).
  Identical on both boots at all three call sites.
- **`schema.rb`** — 8.1's alphabetical column sort is a **no-op** here: the 8.0 and 8.1
  dumps are byte-identical apart from the version header, because
  `fix-db-schema-conflicts` already sorts. Against the committed `[7.2]` file there are
  only 8 diff lines: the header, and `enable_extension "plpgsql"` →
  `"pg_catalog.plpgsql"`. That second one is cosmetic — Rails 8's `extensions` now
  returns the schema-qualified name, and the existing test DB already reports it.
  Load-tested: the 8.1 dump loads into a fresh DB with 148 tables, exit 0.
  This dump change is already pending on the **8.0** boot too, not just 8.1.

#### The primary cutover — done after 8.0 was validated on staging

`Gemfile.lock` is now **rails 8.1.3.1 / postgis 11.1.1 / rgeo-activerecord 8.1.0**.
Lock diff: **15 gems changed, `action_text-trix` added** (Trix was extracted from
actiontext in 8.1), nothing removed, `BUNDLED WITH` still 2.3.5 — exactly the Phase 0
prediction.

Suite on the primary boot at 8.1: **9,880 / 154 failures / 220 pending** — the same
count as 8.0 and as the 8.1 next boot. The single differing example ID is
`new_joint_filers_spec`, which passes in isolation; a known flake.

`gemn` collapsed to plain `gem` for `rails` and `activerecord-postgis-adapter`, since
there is no Rails 8.2 to aim the harness at.

⚠️ **`Gemfile_next.lock` is now a redundant copy of `Gemfile.lock`.** Collapsing `gemn`
left it stale (it held `addressable 2.8.7` against the primary's 2.9.0), which would
have given anyone running `DEPENDENCIES_NEXT=1 bundle install` a subtly different
bundle, and bootboot's sync hook could churn it. It was overwritten with the primary
lock as a stopgap. **Phase 7 should retire the harness properly**: delete
`Gemfile_next.lock`, the `plugin 'bootboot'` line, the `Plugin.send(:load_plugin, ...)`
call, `enable_dual_booting`, and the now-unused `gemn` helper — or repoint it at
`main`/edge if the dual-boot capability is worth keeping for 8.2.

The cutover command, for reference:

```
bundle lock --update rails railties activesupport activerecord actionpack \
  actionview actionmailer activejob activemodel activestorage actioncable \
  actionmailbox actiontext activerecord-postgis-adapter rgeo-activerecord rails-i18n
```

Expect `action_text-trix` to appear (Trix was extracted from actiontext in 8.1).

### Phase 5 — original notes

Same shape as Phase 2/3, driven from the `DEPENDENCIES_NEXT=1` boot:

1. `DEPENDENCIES_NEXT=1` targets `rails ~> 8.1.3`, `activerecord-postgis-adapter ~> 11.1`.
2. Verify the `to_time` behavior change at the three call sites.
3. Verify `db/schema.rb` regenerates cleanly under 8.1's alphabetical column sort and
   that `fix-db-schema-conflicts` does not fight it.
4. Cut over the primary lock with the same targeted `bundle lock --update` invocation.
   Expect `action_text-trix` to appear.

### Phase 6 — `load_defaults 8.1`

Adopt the seven new defaults. The two that need real attention:

- `yjit = !Rails.env.local?` — YJIT in production. Deploy to staging and compare RSS
  and p95 latency in Datadog before promoting.
- `remove_hidden_field_autocomplete` — regenerate Percy baselines.

`escape_json_responses = false` and `escape_js_separators_in_json = false` are safe
here: only 2 `render json:` call sites in `app/`.

### Phase 7 — cleanup

1. Remove `bootboot`, `Gemfile_next.lock`, and the `DEPENDENCIES_NEXT=1` CI job (or repoint them at
   Rails 8.2 / edge and keep the harness).
2. Drop the `minitest` pin; upgrade `minitest`, `shoulda-matchers`, `rubyzip`,
   `statesman`, `sentry-*`, `strong_migrations`, `redis`, `phony` etc. as individual PRs.
3. Revisit `fix-db-schema-conflicts` now that Rails sorts columns natively.
4. Revisit `sass-rails` → `sassc-rails` (deprecated upstream); consider `dartsass-rails`
   or moving remaining SCSS fully into shakapacker.
5. Restore `config.active_support.deprecation` in `config/environments/test.rb`.

## Rollback

Each phase is a single revertible PR, and the two risky phases (4 and 6) change only
`config/application.rb`. The gem cutovers (3 and 5) are `Gemfile` + `Gemfile.lock`
only. The one irreversible-ish item is the `db/schema.rb` version header and column
ordering — harmless, but it will conflict with any in-flight migration PRs, so land
Phase 5 when the migration queue is quiet.
