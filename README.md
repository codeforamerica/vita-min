# vita-min 💊

Vita-Min is a Rails app that helps people access the VITA program through a digital intake form, provides the "Hub" to VITA volunteers for workflow management, messaging, outbound calls, etc to facilitate tax preparation, and a national landing page to find the nearest VITA site.

## Setup 🧰

### Assumptions before first time setup

> ℹ️ These steps assume you are working with a macOS operating system, if that is not the case, some steps may be different. Ask a fellow teammate and we can update these setup steps to include the operating system you are using.

#### Homebrew

There are a few dependencies that are common for many web applications. The first being [Homebrew](https://brew.sh/).It is used to install many different types of packages for macOS.

If you don't already have Homebrew, install it with:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Git

MacOS comes with git installed but you can also [install it with Homebrew](https://git-scm.com/download/mac) if you want:

```sh
brew install git
```

#### Connect GitHub with a SSH key

If you don't have an SSH key on your computer to connect to GitHub, their documentation on [how to add an SSH key](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account) is a good starting point. You will need to have an SSH key to download this repository locally.

#### Git duet

To make pairing commit history easier, we use [git duet](https://github.com/git-duet/git-duet/), which can be installed with:

```sh
brew install git-duet/tap/git-duet
```

### Add credentials

Get the development secret key from LastPass (`development.key`) or ask a teammate who has it set up.

Add it to your configuration:

```sh
# In the root of vita-min
echo "[secret key]" > config/credentials/development.key
```

### Add efile resources locally

In development, we need to download the IRS e-file schemas zip manually from S3.

> ℹ️ We avoid storing them in the repo because the IRS asked us nicely to try to limit distribution.

- Go to [Google Docs](https://drive.google.com/drive/u/0/folders/1ssEXuz5WDrlr9Ng7Ukp6duSksNJtRATa) (ask a teammate if you don't have access) and download the `efile1040x_2020v5.1.zip` and `efile1040x_2021v5.2.zip` files
- Do not unzip the file using Finder or a local app
- Move file to `vita-min/vendor/irs/`
- The next setup script (`bin/setup`) will unzip it for you, or you can do it yourself with:

```
rake setup:unzip_efile_schemas
```

### Setup script

There is a setup script that handles virtually everything with a single command:

```sh
# In the root of vita-min
bin/setup
```

#### Troubleshooting during setup

**Is the server running locally and accepting connections on Unix domain socket "/tmp/.s.PGSQL.5432"?**

If you see this error, `PostgreSQL` is not running. You can get it running with:

```sh
brew services start postgresql
```

If this doesn't fix your problem, you should check if the service is in an `error` state by running this command:

```sh
brew services
```

If it is, you probably need to reead the last 10 lines of the Postgres log file at `/usr/local/var/log/postgres.log`. If it says something about needing an upgrade, try running this:

```sh
brew postgresql-upgrade-database
```

If it gives you an error about needing to remove the postgres.old directory, then you can run this command:

```sh
rm -rf /usr/local/var/postgres.old
```

You can also try uninstalling postgresql & postgis, removing the whole postgres folder and running bin/setup again

```sh
brew services stop postgresql
brew uninstall postgresql
brew uninstall postgis
rm -rf /usr/local/var/postgres
bin/setup
```

See also [this upgrade guide](https://quaran.to/Upgrade-PostgreSQL-from-12-to-13-with-Homebrew)

If this doesn't get Postgres out of `error` state, or you otherwise can't figure out what's going wrong, ask for help in #tax-eng and say that you tried the instructions in the README.

### Run the server

To get the server running run:

```sh
foreman start
```

Foreman will run the following 3 commands:

```sh
rails s
rails jobs:work
bin/webpack-dev-server
```

## Development 💻

In development, you'll need to manually start the delayed_job worker using the following command:

```sh
rails jobs:work
```

### Emails

To see emails in development, run `rails jobs:work`. All emails are printed to its output console.
They are also logged in `tmp/mail/#{to_address}`.

### Run some tests!

#### Run all test suites

To run all test suites (RSpec unit & feature specs, Javascript Jest unit tests).

```sh
bin/test
```

#### Only JavaScript unit tests

We use [Jest](https://jestjs.io/) to run our JavaScript unit tests.

```sh
yarn jest
```

#### RSpec tests

We us [RSpec](https://rspec.info/) to run unit & feature tests.

```sh
# run RSpec unit & feature specs
rspec

# - or -

# run RSpec tests that failed on the last run
rspec --only-failures

# - or -

# run feature specs with Chrome visible
# (Chrome runs in the background normally without this flag enabled)
CHROME=y rspec

# - or -

# run RSpec with test coverage report
COVERAGE=y rspec
```

#### Percy visual diff tests

As an engineer, if you've made changes that _should_ not result in visual changes, but you are afraid they will, Percy can help. Create a pull request in GitHub, then run `bin/percy` locally. This will run the feature specs twice locally -- once on main, then once on your pull request -- and upload both collections to Percy. Percy will add a check in the pull request with a link to the visual comparison as well as print the URL to your console.

[Percy](https://percy.io/) allows us to automatically compare visual changes with screenshots.

We access a `PERCY_TOKEN` from Rails `development` credentials. Ask a teammate about access to development credentials.

Have a new branch with visual changes checked out locally that will then be compared to images taken from `main`.

Run the percy command:

```shell
# In root directory
bin/percy
```

##### How do screenshots get taken?

To take screenshots within a feature spec add the `screenshot: true` flag. Enclose all page assertions within the `screenshot_after` method. See below for example. 

```diff
+ scenario "new feature test", js: true, screenshot: true do
  visit "path/to/new/page"

+   screenshot_after do
      expect(page).to have_selector("h1", text: "Title")
+   end
end
```

### Linter

This repo has `rubocop` installed. To check:

`rubocop [app lib ...]`

The rubocop settings files is in the root directory as `.rubocop.yml`

### Integration with RubyMine

RubyMine integrates Rubocop by default. Settings can be found in the Preferences
menu, under Editor > Inspections > Ruby > Gems and Gem Management > Rubocop.

### Flow Explorer

There's a publicly accessible page (on demo and dev environments) at /flows that lets you skip around quickly between pages in the intake flows.

The flows page tries to show a preview screenshot from each page, captured during specialized capybara runs. To capture updated screenshots:

`rake flow_explorer:capture_screenshots`

They'll be dumped into `public/assets/flow_explorer_screenshots` locally.

You can upload them to the correct S3 bucket with the task `rake flow_explorer:upload_screenshots`

### Translations

We use Transifex for translations.

You can run `tx pull --branch main -l es -f` to download the latest translations from Transifex. Engineers will need an account
within Transifex.

You have to install `tx`. Try these commands.

```sh
mkdir -p ~/bin
cd ~/bin
curl -o- https://raw.githubusercontent.com/transifex/cli/master/install.sh | bash
```

You may have to restart your terminal to have this work.

## Deploying the Application 🚀☁️

Notes on deployment can be found in [docs/deployment](docs/deployment.md).

## Documentation 📚

More documentation can be found in the [docs folder](docs/README.md).
