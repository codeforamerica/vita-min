# vita-min

Vita-Min is a Rails app that helps people access the VITA program through a digital intake form, a "valet" drop-off workflow using Zendesk, and a national landing page to find the nearest VITA site.

## Setup

```bash
# 1. Install Ruby using your preferred installation method. For example, to
# install it with rbenv:
brew install rbenv
rbenv install

# 2. Install postgresql using your preferred installation method. You'll need
# the PostGIS extension as well.
brew install postgresql postgis

# 3. Install bundler & system dependencies
gem install bundler
rbenv rehash
bundle install
brew install imagemagick poppler ghostscript

# 4. Install PDFtk
# Download from: https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg

# 5. Get the secret key from LastPass / someone who has it set up.
echo "[secret key]" > config/master.key
```

## Running background jobs in development

In development, you'll need to manually start the delayed_job worker using the following command:

```shell
rails jobs:work
```

## Run some tests!

The `[options]` and `[path]` are optional.

To run the test suite:

`bundle exec rspec [options] [path]`

To run only the failing tests:

`bundle exec rspec --only-failures`

To run the tests with coverage (path not recommended):

`COVERAGE=y bundle exec rspec [options]`

To run the test suite continuously:

`bundle exec guard`

## Tidy Up!

This repo has `rubocop` installed. To check:

`rubocop [app lib ...]`

The rubocop settings files is in the root directory as `.rubocop.yml`

### Integration with RubyMine

RubyMine integrates Rubocop by default. Settings can be found in the Preferences
menu, under Editor > Inspections > Ruby > Gems and Gem Management > Rubocop.

## Environments

## Deploying the Application

Notes on deployment (and tagged release) can be found in
[doc/environments-and-deployment.md](doc/environments-and-deployment.md).


