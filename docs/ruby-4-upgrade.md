# Ruby 4 upgrade: step by step

How we moved vita-min from Ruby 3.4.10 to 4.0.6 (GYR1-1167). Use it as a checklist for
the next Ruby upgrade too. Swap in the new version numbers.

We used same approach as the Rails upgrade: fix what can be fixed on the old Ruby first, run both Rubies side by
side with bootboot until CI is green on both, then switch over in one small PR.

Purpose: Longetibity and performance. Ruby 4 gets security patches the longest which saves us a second upgrade soon and object allocation (Class#new) got faster and helps allocation heavy Rails app.

## 1. Check that the new Ruby is supported everywhere we run

Before writing any code, confirm an image or stack exists for the exact version:

- **Docker** (Aptible builds from `Dockerfile`): `ruby:4.0.6` on Docker Hub
- **CircleCI**: `cimg/ruby:4.0.6-browsers`
- **Heroku** (review apps): the `heroku/ruby` buildpack supports 4.0.6 on our stack
  (`heroku-26`)

Also read the Ruby release notes (`NEWS.md`) for the version, especially the list of
gems that stop being default gems.

## 2. Install the new Ruby locally

```
rbenv install 4.0.6
rbenv versions          # 4.0.6 should be listed
```

**Don't change `.ruby-version` yet.** The repo stays on the old Ruby until the
cut-over (step 9). `rbenv version` inside the repo should still show 3.4.10 (set by
`.ruby-version`). To run something on the new Ruby, prefix it with
`RBENV_VERSION=4.0.6`. There's no need to change `rbenv global`.

**Error: `make: *** [builtin_binary.rbbin] Segmentation fault: 11` after `linking
miniruby`.** This happens on macOS 26 with Command Line Tools 27: the default SDK is
for a newer macOS than the one you're running. Build against the matching SDK, and
keep it set for `bundle install` too:

```
export SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk
rbenv install 4.0.6
```

## 3. Try the bundle on the new Ruby, in a throwaway copy

The `Gemfile` reads `.ruby-version`, so under 4.0.6 Bundler refuses to run in the
real checkout (`Your Ruby version is 4.0.6, but your Gemfile specified 3.4.10`).
Use a scratch clone instead:

```
git clone --local . /tmp/vita-min-ruby4 && cd /tmp/vita-min-ruby4
echo 4.0.6 > .ruby-version
bundle config set --local path vendor/bundle
bundle install
```

Then boot the app (`bin/rails runner 'p 1'`) and run a spec file. A gem that installs
and `require`s fine on its own can still fail when the app boots, so test the boot.

## 4. Fix the gems that break, on the old Ruby

Ship these on the old Ruby, before switching. Use targeted updates only
(`bundle update --conservative <gem>`). A bare `bundle update` moves hundreds of gems.

| Error on Ruby 4 | Cause | Fix |
| --- | --- | --- |
| `cannot load such file -- ostruct`, **production only** | Not a default gem anymore. We only had it through `axe-core` (test group), so specs passed. | `gem "ostruct", "~> 0.6.0"` in the `Gemfile` |
| `cannot load such file -- fiddle`, on every boot | `pycall` 1.5.1 requires it without declaring it | `bundle update --conservative pycall` (1.5.3) |
| `cannot load such file -- readline`, test env | `byebug` 11 requires it | `bundle update --conservative byebug pry-byebug` (13.0 / 3.12) |

If a new "cannot load such file" shows up, the gem has usually just stopped being a
default gem. Either declare it in the `Gemfile` or bump the gem that requires it.

## 5. Add the production boot check

`bin/check_production_boot` boots the app with only the production gem set and fails
if a stdlib class the app uses isn't loaded. It's the only thing that catches errors
like the `ostruct` one, because the test suite always has the test gems loaded.

It runs `RAILS_ENV=test` against the local test DB and never touches production
config, credentials or data. CI runs it in `run_ruby_tests`.

```
bin/check_production_boot
```

## 6. Run both Rubies side by side with bootboot

bootboot lets one checkout resolve two lockfiles: `Gemfile.lock` for the current Ruby,
`Gemfile_next.lock` for the next one, selected by `DEPENDENCIES_NEXT=1`.

1. In the `Gemfile`, under the line that reads `.ruby-version`, add:

   ```ruby
   ruby_version = '4.0.6' if ENV['DEPENDENCIES_NEXT']
   ```

2. Create the next lockfile:

   ```
   cp Gemfile.lock Gemfile_next.lock
   RBENV_VERSION=4.0.6 DEPENDENCIES_NEXT=1 bundle install
   ```

3. Check that bootboot works:
   - `git diff Gemfile.lock` is empty. The two lockfiles should differ only in
     `RUBY VERSION`.
   - `bundle exec ruby -v` → old Ruby; `RBENV_VERSION=4.0.6 DEPENDENCIES_NEXT=1
     bundle exec ruby -v` → new Ruby.
   - The wrong combination fails with `Bundler::RubyVersionMismatch`. That's expected.

While dual-booting, change gems on the old Ruby as usual. `bundle install` updates
both lockfiles; commit both.

Leave the bootboot setup at the top of the `Gemfile` in place. Only the
`DEPENDENCIES_NEXT` Ruby line comes out at the end.

## 7. Add a CI job for the new Ruby

In `.circleci/config.yml`, `run_ruby_tests` takes `executor`, `lockfile` and
`notify_slack` parameters. Add an executor on `cimg/ruby:4.0.6-browsers` with
`DEPENDENCIES_NEXT: "1"`, and invoke `run_ruby_tests` a second time with it,
`lockfile: Gemfile_next.lock` and `notify_slack: false`. Don't add it to any deploy's
`requires`, so it stays non-blocking.

Push, and fix failures until both jobs are green. For Ruby 4, both were green on the
first run once step 4 was done.

## 8. Build the production image on the new Ruby

The test suite doesn't build the `Dockerfile`, so build it once locally on the new
Ruby (`--platform linux/amd64`). Check that Puma serves `/healthcheck`, a
`delayed_job` job runs, and `rake -T` loads.

Don't use production secrets for this. The `Dockerfile` sources `.aptible.env` and
downloads from S3, so for the local build remove those steps, precompile assets with
`RAILS_ENV=test`, and use `git archive HEAD` as the build context so no local key files
get copied in.

## 9. Switch over

One PR:

- `.ruby-version`, `.tool-versions` → `4.0.6`
- `Dockerfile`, `Dockerfile.local` → `FROM ruby:4.0.6`
- `.circleci/config.yml`: both executors → `cimg/ruby:4.0.6-browsers`; delete the
  next-Ruby executor and the second `run_ruby_tests` invocation
- `Gemfile`: remove the `DEPENDENCIES_NEXT` Ruby line
- Delete `Gemfile_next.lock`, then run `bundle install` on 4.0.6 to rewrite
  `Gemfile.lock` (only `RUBY VERSION` should change)
- `package.json` doesn't need changing; it only pins Node

## 10. Deploy

1. **Review app**: open the PR. Check that the Heroku build uses 4.0.6 and
   `/healthcheck` returns 200.
2. **Staging**: push to `staging`. This replaces what's there, so tell the team. It's
   the first build with `.aptible.env`, the S3 downloads and production config.
   Check jobs, cron and an efile submission. Watch Datadog memory and latency, and
   Sentry.
3. **Demo**: merge to `main`.
4. **Production**: push to `release`.

Rollback: revert the PR and redeploy. A Ruby bump has no migrations.

## 11. Follow-ups

- Replace `OpenStruct` in `app/` (5 places) with `Struct`/`Data`, then drop
  `gem "ostruct"`. `bin/check_production_boot` will catch a missed spot. Do this after Ruby 4 is already in Prod.
- RuboCop bump. 1.53 can't target Ruby above 3.3, and it isn't run in CI.
- Optional: bump Bundler from 2.3.5.
- Remove bin/check_production_boot file after we fix the OpenStruct gem issue.
