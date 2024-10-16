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

#### Assumptions before first time setup

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

#### Clone the repo

You'll want to use SSH to clone

```sh
git clone git@github.com:codeforamerica/vita-min.git
```

#### Git duet

To make pairing commit history easier, we use [git duet](https://github.com/git-duet/git-duet/), which can be installed with:

```sh
brew install git-duet/tap/git-duet
```

After installation, add the following line to your `~/.zshrc` or `~/.bash_profile` file:

```sh
export GIT_DUET_CO_AUTHORED_BY=1
```

This will ensure that git-duet adds co-author information to your commit messages.

#### Adding Credential Files

You need to add the following credential files under the `config/credentials` folder:

- `circleci.key`
- `development.key`
- `demo.key`
- `heroku.key`
- `staging.key`
- `production.key`

You can obtain these keys from internal team members or access them through LastPass if you have the necessary permissions.

#### Add efile resources locally

In development, we need to download the IRS e-file schemas zip manually from S3.

> ℹ️ We avoid storing them in the repo because the IRS asked us nicely to try to limit distribution.

Run this rake task to get a list of missing schemas, where to download them from, and where to put them. You might need to ask CfA staff for access if you do not have access to the Google drives.

```
rake setup:unzip_efile_schemas
```

#### Setup script

There is a setup script that handles virtually everything with a single command:

```sh
# In the root of vita-min
bin/setup
```
> ℹ️ **Note:** If `bundler` is not installing, ensure that you have `rbenv` installed and are not using the system Ruby version. Check the `.ruby-version` file in the repository to match the version specified. If necessary, update to the correct Ruby version and modify your `.zprofile` or `.zshrc` to point to the correct path.

> ℹ️ **Note:** If you encounter Ruby version problems or issues with `foreman` during setup, you may need to initialize `rbenv`. Run the following command in your terminal:
>
> ```sh
> rbenv init
> ```
>
> This will set up rbenv in your shell. You may need to restart your terminal to apply the changes.

> ℹ️ **Note:** You may consider at this point copying or symlinking `.rspec-local.example` to `.rspec-local` to exclude specs that are not core to CfA yet. Copying enables you to set other custom flags for your local environment, symlinking enables the flags to automatically go away when they are removed from the example file. Just be careful not to commit any local changes!

#### Github Auth for Deploys
Our release script utilizes Github cli. Check if you already have Github cli installed (ex: `gh` in your terminal should return a set of commands, if you have it installed). `brew install gh` if you get an `command not found` error.
Run `gh auth login` and follow directions to login (choose Github.com, SSH, login with web browser). If you do not set this up, you will have to manually write up the release notes in Github.

#### Download the GYR Efiler

Download the GYR Efiler to run tests locally by executing:
```sh
rails setup:download_gyr_efiler
```

### Troubleshooting during setup

**Is the server running locally and accepting connections on Unix domain socket "/tmp/.s.PGSQL.5432"?**

If you see this error, `PostgreSQL` is not running. You can get it running with:

```sh
brew services start postgresql
```

If this doesn't fix your problem, you should check if the service is in an `error` state by running this command:

```sh
brew services
```

If it is, you probably need to read the last 10 lines of the Postgres log file at `/usr/local/var/log/postgres.log`. If it says something about needing an upgrade, try running this:

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

#### Java Installation for pdftk on macOS

To run pdftk on macOS, you need to have Java installed correctly. Use the following commands to install Java:

***NOTE:*** We are currently discussing  `asdf` vs `brew`. Feel free to follow whichever set up works better for you for now.

##### asdf instructions:

`asdf` is one big umbrella used to simplify installing and managing versions for our core technologies. The managed techs and desired versions are listed in `.tool-versions` in the vita-min root. To use `asdf`, follow these steps:

1. Install asdf with `brew install asdf`.
2. For each technology you wanna track with asdf, you'll need to install an appropriate plugin. We're talking about Java in this moment, so install the Java plugin with `asdf plugin-add java https://github.com/halcyon/asdf-java.git`
3. Now you can let asdf take the wheel and install/setup Java with `asdf install`.
4. Yay.

You've likely noticed there's other things listed in `.tool-versions`, and it's reasonable to use `asdf` for those things too, but the setup script presumes the use of `brew`, so there may be resulting shell/path conflicts. Use at your own risk.

##### brew instructions:
```sh
AdoptOpenJDK/openjdk && brew install adoptopenjdk8
```

## Run the server

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

## Alternate setup + development with docker compose

1. Make sure you have `development.key` in `config/credentials`. Ask a teammate if you need access.
1. Unpack the state schema files into `vendor/us_states/unpacked`
1. Run `docker compose up`. This will start the database, jobs, shakapacker, and rails app containers. (If you had the app running locally, you may need to stop your local postgres first.)

### Run tests in a docker container
- Developent environment is set by default, and test environment is set by default when you run tests
- Run any of the test commands in an interactive shell in the container named `web`. For example, `docker exec -it web rspec` or `docker exec -it web yarn jest`
- Turbo tests don't work with the current docker setup, so running `docker exec -it web bin/test` won't work as expected

### Useful docker commands
| Command | Meaning |
| ----- | ----- |
| `docker compose up -d --build` | Build, run, and detach from docker compose containers in the default profile |
| `docker compose --profile pgadmin up` | Start the pgadmin service |
| `docker exec -e ALLOWED_SCHEMAS=nj -it web rspec` | Run only the rspec tests that require the allowed schemas |
| `docker exec -it web yarn jest` | Run jest tests |
| `docker logs -f web` | Follow the logs of the rails container |
| `docker volume prune --filter label=vita-min_database` | Get rid of the database entirely |

## Deploying the Application 🚀☁️

Notes on deployment can be found in [docs/deployment](docs/deployment.md).

## Documentation 📚

More documentation can be found in the [docs folder](docs/README.md).
