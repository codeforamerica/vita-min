# Ruby 4 upgrade plan (GYR1-1167)

Status: CUT-OVER READY (2026-09-30). Phases 0–2 done, CI green on 4.0.6, Phase 3
changes prepared; next is deploying (Phase 3, step 2).
Starting on: Ruby 3.4.10, Rails 8.1.3.1, Bundler 2.3.5
Target: latest Ruby 4.0.x patch release

## Summary

Migration path: **prerequisite PRs on 3.4.10 → dual-boot 4.0 via bootboot → flip the
default → clean up.** Same shape as the Rails 8 upgrade
(`docs/2026-09-01-rails-8-upgrade-plan.md`), and it reuses the bootboot harness that
upgrade repaired.

Do not bump `.ruby-version` first and fix whatever breaks. The two previous major
upgrades (2.7 → 3.2 in `a9f10d395`, 3.2 → 3.4.4 in `07de56cef`) each did that, and
each landed as one large PR mixing gem bumps, Ruby-level fixes and spec flake fixes.
Everything that can ship on 3.4.10 should ship on 3.4.10.

⚠️ Items marked **(verify)** are from memory of the Ruby 4.0 release notes and have not
been checked against `NEWS.md` for the exact target patch release. Phase 0 step 1
confirms them.

## Lessons from previous Ruby upgrades

| Upgrade | Commit | What broke / what it took |
| --- | --- | --- |
| 2.6 → 2.7.5 | `a3a150db5` | — |
| 2.7 → 3.2 | `a9f10d395` | Keyword-argument separation broke `rspec-mocks` `.and_call_original` (bumped rspec-mocks). `File.exists?` removed. Psych needed `libyaml` in `Brewfile`. `ddtrace` bump. Node pinned for Heroku. |
| (follow-up) | `9a5b01950` | RuboCop 0.82 → 1.46 in its own PR, because old RuboCop cannot parse newer Ruby. |
| (follow-up) | `750cc7469` | Heroku stack bump, once on Ruby 3. |
| 3.2 → 3.4.4 | `07de56cef` | `csv` and `observer` stopped being default gems, so they were added to the `Gemfile`. `ddtrace` replaced by `datadog`. Node bump. Many flaky JS feature specs fixed (`spec/support/helpers/capybara_helpers.rb`). bootboot added. |
| Patch bumps | `aaaaca16c`, `188c23e03` | Seven files, nothing else. See "Version references" below. |

The pattern: most of the work is **gems that drop out of the default set** and
**native-extension gems that need a newer release**. After that comes **one Ruby
semantic change** (kwargs in 3.0), and the feature-spec flakes that turn up whenever
the suite runs on a new image.

## Version references

Every place that pins the Ruby version. The patch bumps changed exactly these:

- `.ruby-version` (read by the `Gemfile`'s `ruby` directive)
- `.tool-versions`
- `.circleci/config.yml` (two executors, `cimg/ruby:<v>-browsers`)
- `Dockerfile` (`FROM ruby:<v>`; this is the Aptible deploy image)
- `Dockerfile.local`
- `Gemfile.lock` (`RUBY VERSION` section; Heroku's `heroku/ruby` buildpack reads this)
- `Gemfile_next.lock` (only while dual-booting)
- While dual-booting, the next Ruby also appears in two more places: the literal
  `'4.0.6'` in the `Gemfile` (`DEPENDENCIES_NEXT` line) and the
  `rails_executor_next` image in `.circleci/config.yml`. Both are removed at cut-over.

Also stale: `.rubocop.yml:17` `TargetRubyVersion: 3.2.1`. Leave it for the RuboCop
bump in Phase 4, because RuboCop 1.53 can't target anything above 3.3.

## Blockers and risks found in this codebase

### 1. `OpenStruct` will be missing in production only (highest risk)

> **CONFIRMED 2026-09-30 on Ruby 4.0.6:** with production groups only,
> `require "ostruct"` → `LoadError`. See "Verified on Ruby 4.0.6".

**(verify)** Ruby 4.0 moves `ostruct` from a default gem to a bundled gem. Bundled gems
can only be `require`d if they are in the lockfile, the same rule that forced the
`csv` and `observer` additions in `07de56cef`.

`ostruct (0.6.0)` is in `Gemfile.lock` today, but **only as a dependency of
`axe-core-api`**, which comes in through `axe-core-rspec`/`axe-core-capybara` in
`group :development, :test`. `Dockerfile:41` runs
`bundle config set --local without 'test development'`. So:

- **Test suite: passes.** axe-core puts `ostruct` on the load path.
- **Production: `NameError: uninitialized constant OpenStruct`.**

App code using `OpenStruct`:

| File | Why it matters |
| --- | --- |
| `app/models/efile_submission.rb:155,157` | efile submission path |
| `app/lib/submission_builder/state_return.rb:59` | state return XML builder |
| `app/lib/submission_builder/ty2021/return1040.rb:17` | federal return XML builder |
| `app/jobs/bulk_action/send_one_bulk_signup_message_job.rb:30` | background job |
| `app/controllers/hub/portal_states_controller.rb:70` | hub page |

The current CI can't catch this.

**Decision (2026-09-30): declare `gem "ostruct", "~> 0.6.0"` at the top level of the
`Gemfile` now** (next to `csv`/`observer`, the same fix `07de56cef` used). Replace the
five uses in a follow-up ticket; see "Follow-up ticket: replace `OpenStruct` in `app/`"
below. Also add a guard so this class of bug can't come back (see Phase 1, step 4).

### 2. Bundler 2.3.5

> **Update 2026-09-30:** not a hard blocker. Bundler 2.3.5 installed and ran the full
> bundle on Ruby 4.0.6 (see "Verified on Ruby 4.0.6"). Still worth bumping on its own
> timeline. It's a four-year-old Bundler, and every fresh Ruby 4 image will download
> and re-exec into it.

`BUNDLED WITH 2.3.5` dates from early 2022. `Dockerfile:45` and `Dockerfile.local:34`
install exactly the lockfile's version. Ruby 4.0 ships with RubyGems/Bundler 4.x
**(verify)**. A 2022 Bundler running on Ruby 4 is the most likely hard failure, and it
also has to keep working with the bootboot plugin (0.2.2).

Bump Bundler on 3.4.10 in its own PR, before anything else. The Rails 8 plan
deliberately avoided rewriting `BUNDLED WITH`. This upgrade is where that gets paid.

### 3. Other gems leaving the default set

**(verify)** Also promoted to bundled gems in 4.0: `logger`, `benchmark`, `pstore`,
`irb`, `rdoc`, `reline`, `readline`, `fiddle`, `win32ole`. Current state:

| Gem | In lock via | Production-safe? |
| --- | --- | --- |
| `logger` | `activesupport`, `datadog`, `delayed_job`, `faraday`, `mail`, … | Yes (transitive via runtime gems). `config/application.rb:7` requires it directly, so declare it explicitly anyway. |
| `benchmark` | `delayed_job` | Yes, but only transitively. Declare it if app code uses it. |
| `irb`, `rdoc`, `reline` | `railties` → `irb` | Yes |
| `cgi` | `datadog` | Yes. `app/models/vita_provider.rb:68` uses `CGI.escape`. **(verify)** Ruby 4 keeps only `cgi/escape` from the stdlib; confirm `CGI.escape` still resolves in a production-group-only boot. |
| `fiddle` | `pycall` 1.5.3 (added 2026-09-30) | **Was a blocker.** `pycall` 1.5.1 does `require "fiddle"` at boot (`libpython/finder.rb:2`) without declaring it, so every boot on 4.0.6 raised `LoadError`. 1.5.3 declares `fiddle (>= 1.0.0)`. Fixed by a targeted bump; see Phase 1, step 5. |
| `readline` | not in lock | **Was a blocker (dev/test).** `byebug` 11.1.3 requires `readline`, so the test-env boot on 4.0.6 raised `LoadError` and the suite couldn't start. `byebug` 13.0.0 uses `reline` instead. Fixed by a targeted bump; see Phase 1, step 5. |
| `pstore`, `win32ole` | not in lock | No usages found. |

Rule of thumb from 3.4.4: if app code uses it, declare it in the `Gemfile`. Don't rely
on a transitive dependency staying put.

### 4. Native-extension gems

> **Update 2026-09-30:** every gem listed below built and loaded on Ruby 4.0.6 at its
> current locked version, including `sassc`. The one exception was `byebug`: it builds,
> but it can't boot without `readline` (section 3), so it was bumped to 13.0.0. The
> rest are optional housekeeping, not prerequisites. A standalone `require` is not
> enough to prove a gem works; boot the app (`bin/rails runner`) under each Ruby.

These compile against Ruby's C API and are the usual source of `bundle install`
failures on a new major. Several are pinned well behind current:

`pg` 1.5.4, `bootsnap` 1.17.0, `byebug` 11.1.3, `sassc` 2.4.0 (unmaintained),
`datadog` 2.41.0 / `libdatadog`, `ffi` 1.17.4, `nokogiri` 1.19.4, `bcrypt` 3.1.22,
`msgpack` 1.8.3, `nio4r` 2.7.5, `puma` 8.0.2, `rgeo` 3.1.0, `json` 2.21.2.

For each one, find the first release that declares Ruby 4.0 support and do a
**targeted** `bundle update <gem>` on 3.4.10. The same warning as the Rails plan
applies: **do not run a bare `bundle update`.** It crosses many unrelated major
versions.

`sassc` needs special attention. If it doesn't build on 4.0, the fix is replacing the
Sass pipeline (`sass-rails` → `dartsass-rails` or similar), and that's its own project.
Find out in Phase 0.

### 5. Ruby semantic changes (verify)

Grep for each; none are expected to be widespread:

- `Kernel#open` / `IO.open` with a leading `|` no longer spawn a subprocess. Grep of
  `app/` and `lib/` for `open("|` found nothing.
- `Set` is now a core class. Watch for code or gems that monkeypatch `Set` or check
  `Set.instance_method(...).owner`.
- Chilled string literals keep warning on mutation. Fix any warnings on 3.4 first.
- ZJIT and `Ruby::Box` are new and experimental. Leave both off. Keep YJIT as-is
  (`config/application.rb` enables it outside `Rails.env.local?`).

### 6. Deploy targets

- **Aptible** builds from `Dockerfile`. Needs the `ruby:4.0.x` image.
- **Heroku review apps** already use `heroku-26`
  (`.github/workflows/heroku-pull-request.yml:43`), so no stack bump is expected, unlike
  3.2. Confirm the `heroku/ruby` buildpack supports the exact 4.0.x patch.
- **CircleCI** needs `cimg/ruby:4.0.x-browsers`. Check it exists before picking the
  patch version.

## Testing strategy

Same approach as the Rails 8 plan: **chase "no new failures versus a recorded
baseline", not green locally.** CI (with efile schemas downloaded) is the gate.

⚠️ **Record the baseline on or after 2026-10-01.** The Rails plan notes that
`new_joint_filers_spec.rb` and others change behavior when the date crosses
`end_of_intake` (2026-10-01). A baseline recorded today would be invalid tomorrow.

```
bundle exec parallel_rspec -n 8
```

Keep the failing example IDs in `tmp/baseline-3.4.10/` (gitignored), then diff after
each step.

Two additions specific to a Ruby upgrade:

1. **Run the suite once with `RUBYOPT="-W:deprecated"`** on 3.4.10 and fix what it
   reports. This finds most 4.0 breakage while still on 3.4.
2. **Boot the app with only the production gem groups** to catch the `ostruct`-style
   bugs that the test suite hides. Use `bin/check_production_boot`. It loads the
   production **gem set** (no `development`/`test` groups, as `Dockerfile:41`
   installs it), eager loads, and then checks that the stdlib constants `app/` uses at
   runtime (`OpenStruct`, `CSV`, `CGI`, `Base64`, `BigDecimal`, `Logger`) are already
   loaded, without requiring them itself.

   **It never touches a production environment or production data** (changed
   2026-09-30; the first version booted `RAILS_ENV=production`):
   - It runs `RAILS_ENV=test`. The Gemfile has no `:production` group, so the test
     environment minus test gems loads exactly the gems the production image does.
     Production config and credentials are never read.
   - It connects only to the local test database from `config/database.yml`
     (`vita-min_test`), and only reads from it. It needs the schema loaded, because
     eager loading runs `Flipper.enabled?(:use_pundit)` in the body of
     `Hub::UsersController` (line 9).
   - It removes `DATABASE_URL`, `RAILS_MASTER_KEY` and `RAILS_MASTER_KEY_NEW` from its
     environment, and it refuses to run if `RAILS_DB_HOST` isn't `localhost`,
     `127.0.0.1` or `::1`.

   Verified: it passes on 3.4.10 and on 4.0.6 (next boot); it fails with
   `cannot load such file -- ostruct` on 4.0.6 when `gem "ostruct"` is removed; a
   production-looking `DATABASE_URL` and `RAILS_MASTER_KEY` in the shell are ignored;
   and `RAILS_DB_HOST=prod-db.example.com` is refused.

   ```
   bin/check_production_boot                                        # primary Ruby
   RBENV_VERSION=4.0.6 DEPENDENCIES_NEXT=1 bin/check_production_boot  # next Ruby
   ```

## Step-by-step

### Phase 0: research, no code changes

#### Local install gotcha: Command Line Tools 27 on macOS 26

With Command Line Tools 27 installed on macOS 26.x, `rbenv install 4.0.6` fails with
`make: *** [builtin_binary.rbbin] Segmentation fault: 11` right after
`linking miniruby`. The default SDK becomes `MacOSX27.sdk`, which declares and exports
`pipe2`, so `configure` sets `HAVE_PIPE2`. macOS 26's libSystem has no `pipe2`, so
`miniruby` jumps to address 0 in `rb_cloexec_pipe` during `Init_Thread`. It isn't
specific to Ruby 4: any Ruby built on this toolchain hits it. 3.4.10 only works
because it was installed before CLT 27.

Build against the SDK that matches the OS:

```
SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk rbenv install 4.0.6
```

Verified 2026-09-30 on macOS 26.7.1 / CLT 27.0 / ruby-build 20260716: installs
cleanly, `HAVE_PIPE2` is not defined, and OpenSSL 3.6.4 and libyaml 0.2.5 load.
Keep `SDKROOT` set when running `bundle install` on this toolchain too, because
native gem `extconf.rb` checks can misdetect functions the same way. Local builds
have no YJIT unless `rust` is installed (same as today; see `config/application.rb`).

1. ✅ Target is **Ruby 4.0.6**. Release notes reviewed; `ruby:4.0.6`,
   `cimg/ruby:4.0.6-browsers` and Heroku support confirmed (2026-09-30). Still to do:
   update each **(verify)** item above to confirmed or corrected.
2. ✅ `bundle install` on Ruby 4.0.6 in a scratch clone at `2c860c6a8` (2026-09-30).
   See "Verified on Ruby 4.0.6" below.

#### Verified on Ruby 4.0.6

Scratch clone with only `.ruby-version` and `.tool-versions` changed,
`SDKROOT=…/MacOSX26.5.sdk`, gems installed to `vendor/bundle`:

- **Resolves and installs unchanged.** `Bundle complete! 123 Gemfile dependencies, 307
  gems now installed.` The only `Gemfile.lock` diff is `RUBY VERSION` →
  `ruby 4.0.6p0`. No gem needed a version bump to install.
- **Bundler 2.3.5 works.** Ruby 4.0.6 ships Bundler 4.0.16, which notices
  `BUNDLED WITH 2.3.5`, installs 2.3.5 and re-execs itself. bootboot 0.2.2 installed as
  a plugin under it. Downgraded from hard blocker to recommended (see section 2).
- **All native-extension gems load:** `pg`, `bootsnap`, `byebug`, `sassc`, `nokogiri`,
  `bcrypt`, `msgpack`, `nio4r`, `puma`, `ffi`, `rgeo`, `json`, `datadog`. `sassc`
  also compiles Sass correctly (`a b{color:red}`), so the Sass pipeline is not a
  blocker.
- **`ostruct` risk CONFIRMED.** With `BUNDLE_WITHOUT=development:test` (as in
  `Dockerfile:41`), `require "ostruct"` raises `LoadError: cannot load such file --
  ostruct` on 4.0.6, but loads on 3.4.10. With all groups it loads, via axe-core. This
  is exactly the test-passes, production-fails case described in section 1.
- `CGI.escape` works with production groups only (`"a+b"`). `logger` and `benchmark`
  load with production groups only.

**App boot and a first spec file (2026-09-30).** A standalone `bundle install` and
`require` missed two blockers that only show up when the app boots:

- **Production boot** (`bin/check_production_boot`) failed on 4.0.6 with
  `cannot load such file -- fiddle`, from `pycall` 1.5.1. Fixed by bumping `pycall`
  to 1.5.3.
- **Test-env boot** failed on 4.0.6 with `cannot load such file -- readline`, from
  `byebug` 11.1.3. Fixed by bumping `byebug` to 13.0.0 and `pry-byebug` to 3.12.0.
- After both bumps, `bin/check_production_boot` passes on 3.4.10 and 4.0.6. On 4.0.6 it
  fails, as it should, when `gem "ostruct"` is removed.
- `spec/models/efile_submission_spec.rb`: **134 examples, 0 failures on both** 3.4.10
  and 4.0.6. This includes the PDF generation examples that shell out to `pdftk`.
- The lockfiles for the two Rubies differ only in `RUBY VERSION`.

Scratch-clone gotcha: `vendor/pdftk/downloads/*.jar` is gitignored, so a fresh clone
fails every `pdftk` spec with `pdftk executable … not found`. Link the jar from an
existing checkout; it isn't a Ruby 4 issue.

The full suite on 4.0.6 has not been run yet. That is Phase 2.

3. Record the 3.4.10 baseline (on or after 2026-10-01).

### Phase 1: prerequisite PRs, on Ruby 3.4.10

Each ships and deploys on its own.

1. **Bundler bump (optional, can happen any time).** Not required for 4.0.6. If you do
   it: update `BUNDLED WITH`, confirm bootboot still loads, and confirm both
   Dockerfiles build.
2. ✅ **Declare `ostruct` at the top level** (2026-09-30). `gem "ostruct", "~> 0.6.0"`
   in the `Gemfile`. `Gemfile.lock` diff is one `DEPENDENCIES` line; `BUNDLED WITH
   2.3.5` is preserved. Verified with `BUNDLE_WITHOUT=development:test`:
   `require "ostruct"` works on 3.4.10 and on 4.0.6 (it raised `LoadError` on 4.0.6
   before). Replacing the call sites is a follow-up ticket and not a prerequisite for
   the upgrade.
3. ✅ **Declare the bundled gems that app code uses: not needed** (2026-09-30).
   `logger` is a runtime dependency of `activesupport` 8.1 (and `datadog`, `mail`,
   `faraday`, …), so it's always in the production bundle, and
   `bin/check_production_boot` asserts `Logger` is loaded. `app/`, `lib/` and
   `config/` never reference `Benchmark`. `ostruct` was the only real gap (step 2).
4. ✅ **Production-groups boot check** (2026-09-30): `bin/check_production_boot`.
   See "Testing strategy". On 3.4 it passes trivially, because `ostruct` is still a
   default gem there. It starts guarding once it runs in the Ruby 4 CI job (Phase 2,
   step 3). It needs no credentials and never touches production (see "Testing
   strategy" for the safeguards).
5. ✅ **Targeted gem bumps that 4.0.6 requires** (2026-09-30), each via
   `bundle update --conservative`:
   - `pycall` 1.5.1 → 1.5.3, which adds `fiddle` 1.1.8 (same version 4.0.6 bundles)
   - `byebug` 11.1.3 → 13.0.0 and `pry-byebug` 3.10.1 → 3.12.0 (`readline` → `reline`)

   No other gems moved. Worth putting these in one PR with steps 2 and 4, since all
   three are "4.0.6 can't boot without this." The other native-extension bumps
   (`pg`, `bootsnap`, …) stay optional housekeeping.
6. ✅ **RuboCop bump: not a prerequisite; moved to Phase 4** (2026-09-30). RuboCop
   isn't run in CircleCI or GitHub Actions. 1.53.1 produces identical output on
   3.4.10 and 4.0.6 (55 offenses across `app/models/efile_submission.rb` +
   `app/lib/submission_builder/` under both). It can't target 3.4 or 4.0 (max
   `TargetRubyVersion` is 3.3), but the current `3.2.1` target is valid.
7. **Fix deprecation warnings** from the `-W:deprecated` run.

### Phase 2: dual-boot Ruby 4.0

The harness is in place (see the Rails plan, Phase 1, and the comments at the top of
the `Gemfile`). `Gemfile_next.lock` does not exist right now.

1. ✅ **`ruby` directive switches on `DEPENDENCIES_NEXT`** (2026-09-30).
   `Gemfile:3-7`: `.ruby-version` for the primary boot, `'4.0.6'` when
   `DEPENDENCIES_NEXT` is set.
2. ✅ **`Gemfile_next.lock` created** (2026-09-30) with `cp Gemfile.lock
   Gemfile_next.lock` then `RBENV_VERSION=4.0.6 DEPENDENCIES_NEXT=1 bundle install`.
   `Gemfile.lock` is byte-for-byte unchanged; the two lockfiles differ only in
   `RUBY VERSION`. No `gemn` entries were needed. Verified:
   - Primary boot → Ruby 3.4.10 + `Gemfile.lock`; next boot → Ruby 4.0.6 +
     `Gemfile_next.lock`.
   - A mismatch fails loudly with `Bundler::RubyVersionMismatch` in both directions
     (4.0.6 without the variable, 3.4.10 with it).
   - A plain `bundle install` on 3.4.10 leaves both lockfiles alone.
   - **Sync works across Rubies.** In a scratch clone, adding a gem on 3.4.10 made
     bootboot write it to both lockfiles, and `Gemfile_next.lock` kept
     `ruby 4.0.6p0`. So the normal workflow (change gems on 3.4.10, run
     `bundle install`, commit both locks) keeps working during the upgrade.
   - **A fresh checkout works.** With no `.bundle/plugin`, `DEPENDENCIES_NEXT=1
     bundle install` on 4.0.6 installs bootboot on the first pass, touches neither
     lockfile, and `bundle exec` then uses `Gemfile_next.lock`. This is the CI case.

   Local next-boot commands:

   ```
   export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk  # CLT 27 only
   RBENV_VERSION=4.0.6 DEPENDENCIES_NEXT=1 bundle install
   RBENV_VERSION=4.0.6 DEPENDENCIES_NEXT=1 bundle exec rspec <files>
   ```

3. ✅ **CircleCI job** (2026-09-30), `.circleci/config.yml`:
   - New executor `rails_executor_next`: `cimg/ruby:4.0.6-browsers` with
     `DEPENDENCIES_NEXT: "1"`, and the same Postgres/PostGIS service.
   - `run_ruby_tests` takes three parameters: `executor`, `lockfile` (keys the bundle
     cache, so the two Rubies don't share `vendor/bundle`) and `notify_slack`. It's
     invoked a second time as `run_ruby_tests_ruby_4`.
   - **Non-blocking:** no deploy `requires` it, and `notify_slack: false` keeps it from
     paging `@badger` on `main`.
   - New `check_production_boot` step runs `bin/check_production_boot` right after the
     test DB is set up, in **both** jobs, against `vita-min_test` on the job's Postgres.
     On 3.4 it passes trivially; on Ruby 4 it catches the production-only `LoadError`s.
   - Not validated with the CircleCI CLI (not installed locally). Check the first
     pipeline run on this branch.
4. ✅ **Parity in CI** (2026-09-30, commit `14b113cff`). All four jobs green:
   `run_ruby_tests` (3.4.10, job 97766), `run_ruby_tests_ruby_4` (4.0.6, job 97765),
   `run_js_tests`, `run_annotate`. The Ruby 4 job ran the full suite, efile schemas
   included, on `cimg/ruby:4.0.6-browsers`, and the main `parallel_rspec` pass had no
   failures, so the retry pass had nothing to rerun. None of the expected failure
   classes (mocks, removed methods, JS feature-spec flakes) showed up. The Phase 1
   prerequisites covered everything the suite exercises.

   The boot-check step's "passed" line is easy to miss. It comes after Datadog's
   `DATADOG CONFIGURATION` log lines at the end of the step. The step is now named
   "check production boot (production gem set, local test DB)".
5. ✅ **Beyond rspec** (2026-09-30), except the Heroku review app. See below.

#### Production image on Ruby 4.0.6

Built locally from the real `Dockerfile` with only these changes, so no production
secrets or data were involved:

- `FROM ruby:4.0.6` + `ENV DEPENDENCIES_NEXT=1`
- the `.aptible.env` sourcing removed from each `RUN`. That file holds the production
  environment Aptible injects at build time.
- the S3 download step skipped (`setup:download_efile_schemas
  setup:unzip_efile_schemas setup:download_gyr_efiler`), because it needs production
  AWS credentials
- `assets:precompile` run with `RAILS_ENV=test` instead of production config
- build context from `git archive HEAD`, so gitignored files (keys, `.aptible.env`)
  can't get in. `.dockerignore` doesn't exclude them, and `ADD . /app` would copy
  them.

Results, `--platform linux/amd64` (matches production):

- **All 16 stages build.** apt packages, NodeSource/Yarn, pdftk, Temurin 21 JDK,
  `bundle install` (Bundler 2.3.5, bootboot plugin installed on the first pass, **223
  gems, 20 native extensions**, production gem set only) and `assets:precompile`
  (Shakapacker/webpack plus Sprockets/`sassc`).
- Inside the image: `ruby 4.0.6 [x86_64-linux]`, `Gemfile_next.lock`.
  `db:schema:load` works, and **`bin/check_production_boot` passes**. Postgres ran in
  a `cimg/postgres:13.4-postgis` container, and the app container shared its network,
  so the DB was genuinely `localhost`.
- **Web:** Puma 8.0.2 boots on Ruby 4.0.6. `/healthcheck` and `/en` return HTTP 200.
- **Background jobs:** a job queued through `delayed_job` was picked up and performed by
  `Delayed::Worker#work_off` on 4.0.6 (queued 1, remaining 0).
- **Rake:** `rake -T` loads all 133 tasks.

Not covered: the production-env boot itself (needs production credentials, so it's
deliberately not tested locally), the efile schema/efiler downloads, and the
`supercronic` cron runner. The first staging deploy in Phase 3 covers these.

**Heroku review app:** the `heroku/ruby` buildpack reads `RUBY VERSION` from
`Gemfile.lock`, which stays on 3.4.10 until cut-over. So a Ruby 4 review app only
exists on the Phase 3 PR. That's the first step of Phase 3's deploy order anyway.

### Phase 3: cut over

1. ✅ **Cut-over changes prepared** (2026-09-30, uncommitted on
   `GYR1-1167-upgradeto-ruby-4`):
   - `.ruby-version` → `4.0.6`; `.tool-versions` → `ruby 4.0.6` (nodejs unchanged)
   - `Dockerfile` → `FROM ruby:4.0.6`; `Dockerfile.local` → `FROM ruby:4.0.6 AS base`
   - `.circleci/config.yml`: `ruby_executor` and `rails_executor` →
     `cimg/ruby:4.0.6-browsers`. `rails_executor_next` and the
     `run_ruby_tests_ruby_4` invocation are deleted. The `run_ruby_tests`
     parameters (`executor`, `lockfile`, `notify_slack`) stay, with defaults
     identical to the old behavior, ready for the next upgrade's dual-boot job.
   - `Gemfile`: the `DEPENDENCIES_NEXT` Ruby switch is removed. **The bootboot
     harness stays**, as the `Gemfile` comment requires.
   - `Gemfile_next.lock` deleted. `Gemfile.lock` regenerated by `bundle install` on
     4.0.6. It's byte-for-byte the old `Gemfile_next.lock`; the only change from
     `HEAD` is `RUBY VERSION` → `ruby 4.0.6p0`. `BUNDLED WITH 2.3.5` is unchanged.
   - `config/application.rb` YJIT comment → `ruby:4.0.6` image. Verified: the image
     ships YJIT (`RubyVM::YJIT.enabled?` → `true` under `--yjit`) and also ZJIT.

   Verified locally: no `3.4.10` references left outside docs (the matches in
   `config/aws_ip_ranges.json` are AWS IP addresses). `bin/check_production_boot`
   passes on the default Ruby (4.0.6). `efile_submission_spec` +
   `send_one_bulk_signup_message_job_spec`: 140 examples, 0 failures. Ruby 3.4.10 is
   now refused with `Bundler::RubyVersionMismatch`.

   **Every engineer needs Ruby 4.0.6 locally after this merges.** On Command Line
   Tools 27 / macOS 26, see "Local install gotcha" (`SDKROOT=…/MacOSX26.5.sdk`).
2. Deploy: review app → staging → demo → production. Watch Datadog RSS and p95
   latency, and Sentry, for one release. The first review app is also the first Heroku
   build on Ruby 4. The first staging deploy is the first real Aptible build: it
   loads `.aptible.env`, runs the S3 schema/efiler download and boots with production
   config, none of which were tested locally.
3. ✅ `Gemfile_next.lock` deleted (done in step 1).

### Phase 4: follow-ups

- Update `bin/setup`, `Brewfile` and onboarding docs if the local Ruby install steps
  changed.
- Revisit any `gemn` entries or temporary pins added along the way.
- Mark this plan COMPLETE with the final state, like the Rails plan.
- **RuboCop bump** (separate ticket). 1.53.1 → a release that supports
  `TargetRubyVersion: 4.0`, along with `rubocop-performance` 1.16 and `rubocop-rspec` 2.18.
  Expect to regenerate `.rubocop_todo.yml` (2,756 lines today; the last bump,
  `9a5b01950`, rewrote ~2,700). Consider adding it to CI once the todo file is
  regenerated. Until then nothing enforces it.
- **Create a ticket to replace `OpenStruct` in `app/`.** See the next section. Not
  blocking; it can happen before, during or after the upgrade.

## Follow-up ticket: replace `OpenStruct` in `app/`

**TODO: create this ticket.** Suggested title: *Replace OpenStruct in app/ with
Struct/Data and drop the ostruct gem*.

**Why.** The top-level `gem "ostruct"` is a stopgap. `OpenStruct` is slow: each
instance defines singleton methods, which busts method caches. It also returns `nil`
for any misspelled attribute instead of raising, which is how typos in document hashes
hide. RuboCop's `Style/OpenStructUse` flags it. Once `app/` stops using it, the gem
can go.

**Approach.** Prefer `Data.define` (immutable, Ruby 3.2+). Use `Struct.new(...,
keyword_init: true)` only where something mutates the object. Both accept `?` member
names (`Data.define(:valid?)` works; verified on 3.4.10). Unlike `OpenStruct`, they
raise on unknown keys and unknown methods. That's the point, but it means every
consumer has to be traced first. Ship one PR per call site, or group the two submission
builders together.

### 1. Submission builders (highest traffic; do these together)

`app/lib/submission_builder/state_return.rb:59` and
`app/lib/submission_builder/ty2021/return1040.rb:17` share the same line:

```ruby
supported_documents.map { |item| OpenStruct.new(**item, kwargs: item[:kwargs] || {}) if item[:include] }.compact
```

1. List every key used in every `supported_documents` hash under
   `app/lib/submission_builder/` (state subclasses included). Keys seen today: `xml`,
   `pdf`, `include`, `kwargs`, `validate`. Any key you miss becomes an
   `ArgumentError` at submission time.
2. List every method called on the resulting items (`item.xml`, `item.pdf`,
   `item.kwargs`, …) across all `included_documents`, `xml_documents` and
   `pdf_documents` callers.
3. Add `app/lib/submission_builder/included_document.rb`:

   ```ruby
   module SubmissionBuilder
     IncludedDocument = Data.define(:xml, :pdf, :include, :kwargs, :validate) do
       def initialize(xml: nil, pdf: nil, include: false, kwargs: {}, validate: nil)
         super
       end
     end
   end
   ```

   The default values in the custom `initialize` keep the current behavior, where
   omitted keys read as `nil`.
4. Replace both lines with:

   ```ruby
   supported_documents.filter_map { |item| IncludedDocument.new(**item, kwargs: item[:kwargs] || {}) if item[:include] }
   ```

5. Run `spec/lib/submission_builder/` and the state-file submission specs. These need
   the efile schemas (`rake setup:download_efile_schemas setup:unzip_efile_schemas`,
   or rely on CI). Then build one federal and one state submission bundle in a review
   app.

### 2. `EfileSubmission#generate_verified_address`

`app/models/efile_submission.rb:155,157` returns `OpenStruct.new(valid?: true)` as a
stand-in for a `StandardizeAddressService`. The only consumer that uses the return
value is `app/jobs/state_file/build_submission_bundle_job.rb:12`. It calls `valid?`,
and it calls `error_code`/`error_message` only when `valid?` is false, which never
happens for the stub.

1. Replace it with a constant on the model:

   ```ruby
   ALREADY_VERIFIED_ADDRESS = Data.define(:valid?).new(valid?: true)
   ```

   and `return ALREADY_VERIFIED_ADDRESS`. One shared frozen instance is enough.
2. Run `spec/models/efile_submission_spec.rb` (`#generate_verified_address`,
   including `.valid?` at line 378) and
   `spec/jobs/state_file/build_submission_bundle_job_spec.rb`.

### 3. `BulkAction::SendOneBulkSignupMessageJob`

`app/jobs/bulk_action/send_one_bulk_signup_message_job.rb:30` builds a message
object for `SignupFollowupMailer#followup`, which reads `email_body`, `service_type`
and `email_subject` (`app/mailers/signup_followup_mailer.rb`).

1. Define `FollowupMessage = Data.define(:email_body, :service_type, :email_subject)`
   in the job (or the mailer) and pass `FollowupMessage.new(...)`.
2. Check whether the mailer's template (`outgoing_email_mailer/user_message`) reads
   anything else off `message`. Right now any extra attribute would silently be `nil`.
3. Run `spec/jobs/bulk_action/send_one_bulk_signup_message_job_spec.rb` and the
   mailer spec.

### 4. `Hub::PortalStatesController::PseudoTaxReturn#intake`

`app/controllers/hub/portal_states_controller.rb:70` returns
`OpenStruct.new(current_step: @current_step, pseudo?: true)`. It's a fake intake for
the hub page that previews portal states. `app/helpers/tax_return_card_helper.rb:212,231`
reads `intake.pseudo?`.

1. Grep the portal views and `tax_return_card_helper.rb` for every method called on
   `tax_return.intake` along the pseudo path. This is where `OpenStruct` is most
   likely hiding `nil` for methods nobody noticed.
2. Replace it with `PseudoIntake = Data.define(:current_step, :pseudo?)`, nested in
   `PseudoTaxReturn`, adding any members the grep turns up.
3. There's no controller spec for this page. Add a request spec that renders
   `hub/portal_states#index` as an admin and asserts success, then check the page
   manually for each pseudo state.

### 5. Remove the gem

1. `grep -rn OpenStruct app lib config`. It should return nothing.
2. Remove `gem "ostruct"` and its comment from the `Gemfile`, then `bundle install`.
   The lockfile should keep `ostruct` only as an `axe-core-api` dependency.
3. Optionally enable `Style/OpenStructUse` for `app/` in `.rubocop.yml` so it can't
   come back. Specs (14 files use `OpenStruct`) can keep using it, because axe-core
   keeps it in the test bundle. Converting them is optional.
