# Deploying `vita-min`

First, we should be aware of the branches and environments, as these
form the basis of what we deploy _from_, and what we deploy _to_.

Also, this project employs a continuous integration and continuous delivery
system (CI/CD).

## Environments

Details about the environments:

- Staging - an experimental environment. Generally up to date
  with the `main` branch, as it is deployed whenever `main` is
  updated on GitHub, provided the test suite passes.
- Demo - a quality check and demonstration environment. Like Staging,
  it remains up to date with `main` thanks to continuous deployment.
  Unlike Stating, it is rarely used for experimentation.
- Production - the public, visible environment. The Production environment
  is the deploy target of the `release` branch. Like other environments,
  the deployment is performed automatically.

## Branches

- `main` - this is the central trunk of `vita-min` development. This branch
  contains the most up-to-date code, merged in from various work branches. The
  `main` branch is deployed to the Demo and Staging environments
  automatically.
- `release` - this branch represents the code currently in the Production
  environment. It tends to lag behind `main` by a few commits. The `release`
  branch is deployed to the Production environment automatically.
- work branches - most development occurs in a work branch. These branches form
  the sources for Pull Requests on GitHub, and a place to work without
  disrupting the `main` branch.

## How to Deploy

## To the Staging and Demo Environments

To deploy to Demo and Staging, commit/merge to `main` and push to
Github. This will trigger a CI/CD build and deploy to both the Demo and Staging
environments.

### Deploying to Staging Directly

TODO: elaborate on this process, with instructions on force-pushing and
recovery.

At times, you will want to push code to Demo or Staging without going
through the automated deploy process. Manual deployment should be limited
to situations where a temporary solution is called for.

Good candidates:

- pushing a spike for review by stakeholders
- manually testing internals or integration with a 3rd party (e.g. Sentry)

## To The Production Environment

To deploy to Production, run the `bin/release` script from the project root. In
most cases, you will want to run this from the `main` branch. It can be run
from a different branch, however this may complicate subsequent releases
_unless_ the `release` branch is merged back into `main` after the fact.

This script will undertake all the necessary steps for a deployment. If there is
a merge conflict when merging `main` into `release`, the conflicts must be
resolved by hand, then re-run `bin/release`.

The script also creates a tag. For regular releases, we use `version-N.N.N`,
incrementing the appropriate number. Please consult
[semver.org](https://semver.org) for advice on semantic versioning.

The steps the `bin/release` script automates are as follows:

1. fetches from origin
2. prompts for new tag name
3. opens editor with template, includes list of changes
4. merges current branch (usually `main`) into `release`
5. creates tag and GitHub release using `hub` tool

After this, CircleCI runs and deploys if the tests pass.

### Releasing without `bin/release`

To issue a release without using the script, follow the steps listed above:

1. `git pull` the main and release branches
2. from the `release` branch, `git merge --ff main`
3. `git tag <version name>` with the next version
4. `git push && git push --tags`

To issue a release from Github, use the same naming convention,
but begin by clicking the 'releases' button on the main page.
Github provides useful documentation [here](https://help.github.com/en/github/administering-a-repository/managing-releases-in-a-repository).

### Hotfixing

It may be necessary in some circumstances to trigger a deploy of code that isn't on master. Here is a set of steps you can follow.

1. `git fetch` to make sure you have the latest code
1. `git checkout release` to switch to the release branch
1. `git reset --hard origin/release` to make your release branch match what's on GitHub
1. `git log` to validate that you're on an identical commit to `origin/release`
1. Make whatever commits you need to make. Consider `git cherry-pick` to grab individual commits from main. For example `git cherry-pick commitId` will grab a commit whose ID is `commitId`.
1. `git tag version-N.N.N` with the next version. You can find the previous versions listed on the GitHub releases page, or in the output of `git tag`.
1. `git push --tags` to push the tag to GitHub
1. `git push origin release` to push the release branch to GitHub. This will trigger the hotfix deploy.

Check CircleCI and see that it's going out.

Now we'll merge the hotfix code into main to avoid merge conflict confusion down the road.

1. `git checkout main` to switch to the main branch
1. `git merge release` to merge the code into main
1. `git push` to push the changes to main to GitHub

#### Work on the `release` Branch

You can check out and work directly on the `release` branch, performing a `push`
when complete. You should immediately merge `release` into `main`.

#### Work on a Hotfix Branch

Create a hotfix branch directly from `release` (rather than `main`) if a PR is
recommended. When creating the PR, set the PR to target `release` rather than
`main`. When reviewed and merged, merge `release` back into `main`.

## Other Release-related Tools

To view a detailed list of releases, visit https://github.com/codeforamerica/vita-min/releases

To view a list of tags (with the highest releases at the top):

`git tag | sort --version-sort -r`

To view a list of releases with their SHAs (latest first):

`bin/show-tags`

To tag a release:

`git tag version-N.N.N`

Once a release has been tagged, you'll want to push the tag to GitHub:

`git push --tags`

## Manual Deployment
