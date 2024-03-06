# vita-min 💊




Vita-Min is a Rails app that helps people access the VITA program through a digital intake form, provides the "Hub" to VITA volunteers for workflow management, messaging, outbound calls, etc to facilitate tax preparation, and a national landing page to find the nearest VITA site.

## Background

The IRS provides endpoints where approved clients can file both Federal and State taxes on behalf of users in XML and PDF format. They also provide a detailed collection of XML Schemas and PDF forms for this purpose. This project contains a web app that gathers information from files that are used by those endpoints to file taxes on their behalf. There are actually 3 parts to this web app:

* GYR (Get Your Refund) for filing Federal taxes
* State File for filing State taxes (Currently AZ and NY - written after GYR)
* Hub for Volunteers

### [Setup tasks for acquiring XSDs and PDF froms from preset locations](lib/tasks/setup.rake)

We maintain collections of the XSD and PDF forms in S3. This task downloads / unzips these to [vendor/irs](vendor/irs) and [vendor/us_states](vendor/us_states)

### Notable constructs

* [EfileSubmission](app/models/efile_submission.rb) : Data which was submitted / to be submitted to the IRS.
* Intakes : Data being gathered for from a filer that will be needed to build a submission for state file [StateFileNyIntake](app/models/state_file_ny_intake.rb) / [StateFileAzIntake](app/models/state_file_az_intake.rb)
* [efile](app/lib/efile) : Code for calculating values to be placed in the XML. Following the pattern here means that debugging via the 'Explain calculations' tab is possible
* [pdf_filler](app/lib/pdf_filler) : Code for taking XML data and populating PDFs (Typically, PDFs are populated from the XML which is schema bound - calculations should be done in [efile](app/lib/efile)).

### WebApp

The data collected by the IRS does not match up exactly with forms that will be easily understood by a filer, so a little bit of translation is required e.g.: `EligibleForChildTaxCreditInd` can be derived based on the age of the dependent and the relationship to the filer, so we derived this rather than presenting a checkbox a filer has to work out themselves.

For state file, we actually redirect filers to the IRS's efile service, and then get the resultant XML via a back channel when they are finished. We then gather remaining required data to file taxes for the appropriate State.

The remaining business logic mostly concerns login and session management, filing with efile, checking the status of submissions, and alerting users as to the status of their submission.

### IRS Endpoints & SOAP

SOAP interactions with the IRS are handled by a java project - [GYR eFiler](https://github.com/codeforamerica/gyr-efiler)
This is coordinated through [GyrEfilerService](app/services/gyr_efile_service.rb)

### Background Jobs

ActiveJob is used to manage building submission files, with statesman used to define states and actions for submissions.
e.g.: [app/state_machines/efile_submission_state_machine.rb](app/state_machines/efile_submission_state_machine.rb)

### Security

We use [devise to secure access to resources](config/initializers/devise.rb)

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

### Add efile resources locally

In development, we need to download the IRS e-file schemas zip manually from S3.

> ℹ️ We avoid storing them in the repo because the IRS asked us nicely to try to limit distribution.

Run this rake task to get a list of missing schemas, where to download them from, and where to put them.

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
bin/shakapacker-dev-server
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

## Deploying the Application 🚀☁️

Notes on deployment can be found in [docs/deployment](docs/deployment.md).

## Documentation 📚

More documentation can be found in the [docs folder](docs/README.md).
