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

### Install PDFtk

[PDFtk](https://en.wikipedia.org/wiki/PDFtk) is a toolkit for manipulating PDF documents. Download and install PDFtk from https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg

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

- Go to [Google Docs and download this file](https://drive.google.com/drive/u/0/folders/1ssEXuz5WDrlr9Ng7Ukp6duSksNJtRATa) (ask a teammate if you don't have access) and download the `efile1040x_2020v5.1.zip` file
- Do not unzip the file using Finder or a local app
- Move file to `vita-min/vendor/irs/`
- The next setup script (`bin/setup`) will unzip it for you, or you can do it yourself with:

```
rake setup:unzip_efile_schemas
```

#### If you need to unzip files without running the repo setup script

If you already have this repo setup locally, but still need to setup efile schemas, get the efile schemas zip file as explained above and then run

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

### Run the server

If you don't have rails installed, you can follow the [official getting started guide](https://guides.rubyonrails.org/getting_started.html#creating-a-new-rails-project-installing-rails-installing-rails).

With Rails installed, you can serve the application with:

```sh
rails server

# or for short
rails s
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

## Deploying the Application 🚀☁️

Notes on deployment can be found in [docs/deployment](docs/deployment.md).

## Documentation 📚

More documentation can be found in the [docs folder](docs/README.md).
