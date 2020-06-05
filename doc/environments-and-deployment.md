# Environments

TODO: complete this documentation.

## Demo

What is it used for? Who looks at it?

Notes on the deployment environment, if inobvious.

## Staging

What is it used for? Who looks at it?

Notes on the deployment environment, if inobvious.

## Production

What is it used for? Who looks at it?

Notes on the deployment environment, if inobvious.

# Deployment

This project deploys to its environments in two primary
ways. Automated deployments are run as part of the continuous
integration process, and manual deployments can occur if needed.

## Automated Deployment

Automated deployment should be the primary deployment method used.
Allowing deployments only when CI has passed ensures that no known
issues make it into a deployment environment (as long as the test
coverage is sufficient).

### When To Use

The CI environment deploys if its criteria are met. At present, CI deploys
from the `master` branch to both Demo and Staging whenever the test suite
passes. For the Production environment, CI will deploy when changes have been
pushed to the `release` branch.

### How To Deploy

To deploy to Demo and Staging, commit/merge to `master` and push to
Github. This will trigger a CI build and deploy.

To deploy to Production, run the `bin/release` script from the project root.
This will undertake all the necessary steps for a deployment. If there is a
merge conflict when merging `master` into `release`, the conflicts must be
resolved by hand, then re-run `bin/release`.

The script also creates a tag. For regular releases, use `version-N.N.N`,
incrementing the appropriate number. Please consult
[semver.org](https://semver.org) for advice on semantic versioning.

The steps the `bin/release` script automates are as follows:

1. fetches from origin
2. prompts for new tag name
3. opens editor with template, includes list of changes
4. merges current branch (usually `master`) into `release`
5. creates tag and GitHub release using `hub` tool

After this, CircleCI runs and deploys if the tests pass.

### Releasing without `bin/release`

To issue a release without using the script, follow the steps listed above:

1. `git pull` the master and release branches
2. from the `release` branch, `git merge --ff master`
3. `git tag <version name>` with the next version
4. `git push && git push --tags`

To issue a release from Github, use the same naming convention,
but begin by clicking the 'releases' button on the main page.
Github provides useful documentation [here](https://help.github.com/en/github/administering-a-repository/managing-releases-in-a-repository).

### Hotfixing

### Other Release-related Tools

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

At times, you will want to push code to Demo or Staging without going
through the automated deploy process. Manual deployment should be limited
to situations where a temporary solution is called for.

### When To Use

Good candidates:

- pushing a spike for review by stakeholders
- manually testing internals or integration with a 3rd party (e.g. Sentry)
- releasing a hotfix to be overwritten in the main development line shortly

### How To Deploy

TODO: note how to push to deployment environments, without including the
targets in this public repo.
