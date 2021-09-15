# Deploying `vita-min`

First, we should be aware of the branches and environments, as these
form the basis of what we deploy _from_, and what we deploy _to_.

Also, this project employs a continuous integration and continuous delivery
system (CI/CD).

## Environments

Details about the environments:

- Staging - an experimental environment. It is deployed manually as engineers choose.
- Demo - an acceptance testing and demonstration environment. It remains up to date with `main` thanks to continuous deployment.
  Unlike Staging, it is rarely used for experimentation.
- Production - the public, visible environment. The Production environment
  is the deploy target of the `release` branch. Like other environments,
  the deployment is performed automatically.
  
Links to the environments:

* Demo: [GYR](https://demo.getyourrefund.org), [CTC](https://ctc.demo.getyourrefund.org), [Spanish-by-default](https://demo.mireembolso.org)
* Staging: [GYR](https://staging.getyourrefund.org), [CTC](https://ctc.staging.getyourrefund.org), [Spanish-by-default](https://staging.mireembolso.org)
* Production: [GYR](https://www.getyourrefund.org), [CTC](https://www.getctc.org), [Spanish-by-default](https://www.mireembolso.org)

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

### Rolling back

A deployment can be safely rolled back so long as the code you're rolling-back to can read a database version
created by the new code. Our rollback process does not run reverse migrations.

There are three steps to performing a rollback:

1. Identify the commit you wish to roll back to
2. Say on Slack you'll do a rollback
3. Force-push the old commit ID to Aptible
4. Force-push the old commit ID to the release branch

#### Identifying the commit to roll back to

To roll back to a version, you'll need either its `version-x.y.z` name, or a git commit ID, or another ID git understands.
Visit the [releases page](https://github.com/codeforamerica/vita-min/releases) to find the release you want to roll back to.
The release script will print a message like this the end of execution:

> 🧷 Old release was: version-1.2.3

Copy this ID to your clipboard.

#### Say on Slack you'll do a rollback

On #gyr-eng and #gyr-team please write something like the following:

> Performing a rollback to version-1.2.3

#### Push the old commit ID to Aptible

The fastest way to rollback is to directly push this ID to Aptible. Assuming you want to roll back to `version-1.2.3`,
you can do so with:

```
git fetch aptible-prod
git push aptible-prod version-1.2.3:master --force-with-lease
```

This approach is best for a fast rollback. It needs to be a force push in order to go backwards in git history.
It is faster than pushing release first because it skips CircleCI. You must use the branch name `master` because that
is Aptible's main branch.

If you do not have the `aptible-prod` git remote, you can add it with this command, then re-try the push.

```
git remote add aptible-prod git@beta.aptible.com:vita-min-prod/vita-min-prod.git
```

#### Push the old commit ID to the release branch

It's good to keep the `release` branch up to date. Assuming you are rolling back to `version-1.2.3`, you can run:

```
git push origin version-1.2.3:release --force-with-lease
```

This will trigger CircleCI, and CircleCI may or may not have difficulty with the final step of releasing to Aptible
production. Since you already released to Aptible production, this is peaceful.

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
