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
passes. For the Production environment, CI will deploy if a new version
has appeared as a git tag.

### How To Deploy

To deploy to Demo and Staging, commit/merge to `master` and push to
Github. This will trigger a CI build and deploy.

To deploy to Production, tag the release using a [semantic
version](https://semver.org/):

For regular releases, use `version-N.N.N`, incrementing the appropriate number.

For hotfix releases, use `version-N.N.N.N`, incrementing the last digit from
zero.

To view a list of releases (with the highest releases at the top):

`git tag | sort -nr`

To generate the next release number:

`bin/reversion`

To view a list of releases with their SHAs:

`bin/show-tags`

To tag a release:

`git tag version-N.N.N`

Once a release has been tagged, you'll want to push the tag to GitHub:

`git push --tags`

After this, the commit will begin processing (and deploying) in CircleCI.

To issue a release from Github, use the same naming convention,
but begin by clicking the 'releases' button on the main page.
Github provides useful documentation [here](https://help.github.com/en/github/administering-a-repository/managing-releases-in-a-repository).

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
