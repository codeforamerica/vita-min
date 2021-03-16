# vita-min

Vita-Min is a Rails app that helps people access the VITA program through a digital intake form, a "valet" drop-off workflow using Zendesk, and a national landing page to find the nearest VITA site.

## Setup

### Assumptions before first time setup

> ℹ️ These steps assume you are working with a macOS operating system, if that is not the case, some steps may be different. Ask a fellow teammate and we can update these setup steps to include the operating system you are using.

There are a few dependencies that are common for many web applications. The first being [Homebrew](https://brew.sh/).It is used to install many different types of packages for macOS.

If you don't already have Homebrew, install it with:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

MacOS comes with git installed but you can also [install it with Homebrew](https://git-scm.com/download/mac) if you want:

```shell
brew install git
```

If you don't have an SSH key on your computer to connect to GitHub, their documentation on [how to add an SSH key](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account) is a good starting point. You will need to have an SSH key to download this repository locally.

### Install PDFtk

[PDFtk](https://en.wikipedia.org/wiki/PDFtk) is a toolkit for manipulating PDF documents. Download and install PDFtk from https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg

### Add credentials

Get the development secret key from LastPass (`development.key`) or ask a teammate who has it set up.

Add it to your configuration:

```shell
# In the root of vita-min
echo "[secret key]" > config/credentials/development.key
```

### Setup script

There is a setup script that handles virtually everything with a single command:

```shell
# In the root of vita-min
bin/setup
```

#### Troubleshooting during setup

**Is the server running locally and accepting connections on Unix domain socket "/tmp/.s.PGSQL.5432"?**

If you see this error, `PostgreSQL` is not running. You can get it running with:

```shell
brew services start postgresql
```

### Run the server

Is this all that's needed?

```shell
bin/rails server

# or for short
bin/rails s
```

## Development

In development, you'll need to manually start the delayed_job worker using the following command:

```shell
bin/rails jobs:work
```

### Emails

To see emails in development, run `bin/rails jobs:work`. All emails are printed to its output console.
They are also logged in `tmp/mail/#{to_address}`.

### Run some tests!

```sh
bin/test # run all test suites (RSpec unit & feature specs, Javascript Jest unit tests)
yarn jest # run Jest Javascript unit tests
rspec # run RSpec unit & feature specs
rspec --only-failures # run RSpec tests that failed on the last run
CHROME=y rspec # run feature specs with Chrome visible
COVERAGE=y rspec # run RSpec with test coverage report
```

### Linter

This repo has `rubocop` installed. To check:

`rubocop [app lib ...]`

The rubocop settings files is in the root directory as `.rubocop.yml`

### Integration with RubyMine

RubyMine integrates Rubocop by default. Settings can be found in the Preferences
menu, under Editor > Inspections > Ruby > Gems and Gem Management > Rubocop.

## Deploying the Application

Notes on deployment can be found in [docs/deployment](docs/deployment.md).

## Documentation

More documentation can be found in the [docs folder](docs/README.md).
