# vita-min

Vita-Min is a Rails app that helps people access the VITA program through a digital intake form, a "valet" drop-off workflow using Zendesk, and a national landing page to find the nearest VITA site.

## Setup

1.  Install the project dependencies.
    To do so using homebrew, you can run the following from the project root: 
    
    ```bash
    brew bundle
    ```

1.  Install Ruby (for example with rbenv):
 
    ```bash
    rbenv install
    ```

1.  Install the bundler gem and use to install the project gems:

    ```bash
    gem install bundler
    rbenv rehash
    bundle install
    ```

1.  Install frontend dependencies:

    ```bash
    yarn
    ```

1.  Download and install PDFtk from
    https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg

1.  Get the secret key from LastPass / someone who has it set up.
    Add it to your configuration:

    ```bash
    echo "[secret key]" > config/master.key
    ```

1.  Initialize the database:

    ```bash
    rails db:terraform
    ```

## Running background jobs in development

In development, you'll need to manually start the delayed_job worker using the following command:

```shell
rails jobs:work
```

## Run some tests!

```sh
bin/test # run all test suites (RSpec unit & feature specs, Javascript Jest unit tests)
yarn jest # run Jest Javascript unit tests
rspec # run RSpec unit & feature specs
rspec --only-failures # run RSpec tests that failed on the last run
CHROME=y rspec # run feature specs with Chrome visible
COVERAGE=y rspec # run RSpec with test coverage report
```

## Tidy Up!

This repo has `rubocop` installed. To check:

`rubocop [app lib ...]`

The rubocop settings files is in the root directory as `.rubocop.yml`

### Integration with RubyMine

RubyMine integrates Rubocop by default. Settings can be found in the Preferences
menu, under Editor > Inspections > Ruby > Gems and Gem Management > Rubocop.

## Environments

Notes on environments can be found in [doc/environments.md](doc/environments.md).

## Deploying the Application

Notes on deployment can be found in [doc/deployment.md](doc/deployment.md).



