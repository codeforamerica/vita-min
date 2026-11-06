# Performance Tests for Vita-min

JMeter performance tests are provided for local and staging environments.

We use environment variables defined in `jmeter_test` to customize the environment to which we
point. (dev or staging).

## Prerequisites

 * A Recent version of Java should be installed
 * JMeter should be installed
 * The JMeter /bin directory should be in the PATH. Either:
    * Update /etc/paths
    * Add `export PATH="$PATH:<JMETER_INSTALL_DIR>/bin"` to $HOME/.zprofile or $HOME/.bash_profile

## Usage

`jmeter_test -t <TEST_PLAN> [-e dev|staging|production] [-p PORT] [-l LABEL] [-r] [-g] [-- <extra jmeter args>]`

 * `-e` environment (default `dev`). `production` also requires `I_HAVE_APPROVAL_TO_LOAD_TEST_PRODUCTION=yes`.
 * `-p` override the port (e.g. to compare two local servers)
 * `-l` label added to the result file names (e.g. `baseline`, `fix`)
 * `-r` also generate JMeter's HTML dashboard report
 * anything after `--` is passed to JMeter, e.g. `-- -Jpreparer_threads=60`

Results are written to `results/<plan>-<env>-<port>[-<label>]-<timestamp>.jtl` (and `-report/` with `-r`).

## Examples

 * `jmeter_test/jmeter_test -t fyst_az_5_minute_stress_test` : Run `fyst_az_5_minute_stress_test` plan against dev
 * `jmeter_test/jmeter_test -t fyst_az_5_minute_stress_test -e staging` : Run `fyst_az_5_minute_stress_test` plan against staging
 * `jmeter_test/jmeter_test -t fyst_az_5_minute_stress_test -g` : Open `fyst_az_5_minute_stress_test` plan in GUI
 * `jmeter_test/jmeter_test -t hub_clients_personas -r` : Run the hub personas plan against dev and build an HTML report

## Hub clients personas (`hub_clients_personas.jmx`)

Simulates hub staff using `/hub/clients` and the pages they visit around it. It only signs in and loads
pages (GET requests); it never changes data or sends messages. Each persona is a JMeter thread group,
and each thread signs in once and then repeats its flow with think time between pages until the test ends.

| Persona | Accounts file | Flow (one loop) |
|---|---|---|
| A: Volunteer preparer (team member, site coordinator) | `preparers.csv` | My clients → a client's profile, documents, messages, notes → search |
| B: Triage lead (org lead, admin) | `triage.csv` | All clients → a filter from `triage_filters.csv` → page 2-5 → search → a client's profile |
| C: Greeter | `greeters.csv` | Clients to greet → a client's profile → my clients |

Request names (`A1`, `B2`, ...) show up in results, so you can compare the same step across runs.
Requests carry the user agent `vita-min-jmeter-hub-personas` so they can be found or excluded in Datadog.

### Settings (pass with `-- -Jname=value`)

| Property | Default | Meaning |
|---|---|---|
| `preparer_threads` / `triage_threads` / `greeter_threads` | 6 / 3 / 1 | Concurrent users per persona (the mix). 0 turns a persona off. |
| `duration_seconds` | 300 | How long the test runs |
| `ramp_up_seconds` | 30 | Time to start all users |
| `think_time_min_ms` / `think_time_range_ms` | 2000 / 4000 | Pause between pages: min + random(0..range) |
| `data_dir` | set by `-e` | Folder with the CSV files (`data/local`, `data/staging`, `data/production`) |

The default mix (60% preparers, 30% triage, 10% greeters) is a placeholder. Replace it with ratios from
Datadog (hub request logs grouped by user role) once we have them.

### Step by step: local

1. Load realistic data into a separate database, so your dev data isn't touched:
   ```sh
   export DATABASE_URL=postgis://postgres:password@localhost:5432/vita-min_perf
   bin/rails db:create db:schema:load db:seed
   bin/rails runner scripts/synthetic_data.rb generate 5000
   ```
2. Start the app against that database (tracing off to keep logs clean):
   `DD_TRACE_ENABLED=false DATABASE_URL=$DATABASE_URL bin/rails s -p 3000`
3. Smoke test (about 45 seconds, one user per persona) and check there are no errors:
   ```sh
   jmeter_test/jmeter_test -t hub_clients_personas -l smoke -- -Jpreparer_threads=1 -Jtriage_threads=1 -Jgreeter_threads=1 -Jduration_seconds=45
   ruby jmeter_test/summarize_results.rb smoke
   ```
   The local accounts in `data/local/` are the dev seed users from `app/lib/seeder.rb`.
4. Run the real test and open the HTML report (`index.html` inside the run's `results/...-report/` folder):
   `jmeter_test/jmeter_test -t hub_clients_personas -r`

**Comparing two versions of the code** (e.g. before and after a performance fix): run each version on its
own port against the same database (e.g. `git worktree add ../vita-min-baseline origin/main` and start it
on 3001, your branch on 3002), run the plan once per port, then compare per request:
```sh
jmeter_test/jmeter_test -t hub_clients_personas -p 3001 -l baseline -r && \
  jmeter_test/jmeter_test -t hub_clients_personas -p 3002 -l fix -r
ruby jmeter_test/summarize_results.rb baseline fix
```
`summarize_results.rb` takes labels (the `-l` value; it picks the newest matching run) or exact `.jtl` paths.
Run them one after the other, not at the same time, so they don't compete for CPU and the database.
Local numbers come from development mode on a laptop: use them to compare versions, not to predict staging.

**Scenarios** (same commands, different mix):
 * Baseline mix: defaults
 * 10x preparers: `-- -Jpreparer_threads=60`
 * Preparers and triage leads at the same time, heavy: `-- -Jpreparer_threads=30 -Jtriage_threads=15`
 * One persona alone (to isolate it): `-- -Jtriage_threads=0 -Jgreeter_threads=0`

### Step by step: staging

1. Get test accounts on staging, one or more per persona, with password sign-in. Emails on Google-login
   domains (e.g. `@codeforamerica.org`) must use Google sign-in and won't work. Use addresses like
   `loadtest+preparer1@example.com`, with roles and organizations that can see the test clients.
2. Make sure staging has enough clients for the list pages to be full (25 rows). `scripts/synthetic_data.rb`
   can generate them, but it creates records, so agree on that with the team first.
3. Copy `data/example/` to `data/staging/` and fill in the accounts and search terms (names that exist on
   staging). `data/staging/` is gitignored: never commit real credentials.
4. Tell the team (and anyone watching alerts) when you're running it.
5. Smoke test from your laptop with one user per persona:
   `jmeter_test/jmeter_test -t hub_clients_personas -e staging -l smoke -- -Jpreparer_threads=1 -Jtriage_threads=1 -Jgreeter_threads=1 -Jduration_seconds=60`
6. For real load, run from AWS (see "Running in AWS" below; add `hub_clients_personas.jmx` and `data/staging/`
   to the image and change `entrypoint.sh`), not from a laptop, so anti-DDoS protection doesn't block it.
7. Compare before and after a deploy with `summarize_results.rb` (client-side times) and in Datadog
   (server-side times, query counts per request): filter APM/logs to the test window and, if needed,
   to the `vita-min-jmeter-hub-personas` user agent.

### Production

Avoid it. The hub shows real clients' personal data, staff are using it, and a slow hub during tax season
delays people's refunds. If there's a real reason (e.g. staging can't reproduce something):

 * get explicit approval from the team lead / on-call first, and run outside working hours and outside tax season peaks
 * use dedicated test accounts that can only see a test organization with no real clients
 * keep load low (start with 1 user per persona) and watch Datadog while it runs, ready to stop it (Ctrl-C)
 * the script refuses to run unless you set `I_HAVE_APPROVAL_TO_LOAD_TEST_PRODUCTION=yes`
 * accounts go in `data/production/` (gitignored)


## Running in AWS

While running JMeter from a local developer machine is possible (and necessary for developing test plans), testing production-like environments must be done within AWS to not trigger anti-DDOS protections.

Use these instructions to create a docker image that can be deployed to Fargate / ECS for testing production-like environments.

 * Download docker from https://docker.com
 * Cd into the `jmeter_tests/` directory, and create an image with `docker build -t jmeter_test .`
 * Make sure your local AWS config (in $HOME/.aws) contains your credentials for AWS.
 * Create a Repository in Amazon Elastic Container Registry (ECR). I created `vita-jmeter-test` in https://us-east-1.console.aws.amazon.com/ecr/private-registry/repositories?region=us-east-1
 * Push your docker image to your Repository. (Click "View Push commands" at https://us-east-1.console.aws.amazon.com/ecr/private-registry/repositories?region=us-east-1)
 * Create a fargate cluster at https://us-east-1.console.aws.amazon.com/ecs/v2/clusters?region=us-east-1 (I created `vita-jmeter-test`)
 * Create a task to run your docker image on your cluster. For "Compute Options", I chose "Launch Type" with "FARGATE".
   My application type was "Task", and "jmeter-test" was the "Family". For "Networking", I chose the "tax-benefits-dashboards-vpc" with all subnets.
   I chose the "default" and "VPN Security Group" Security Groups. I enabled a public IP.

### Retrieving Results

There are 2 main sources for test result data:
* Datadog will contain logs from rails (Query times, total duration as measured server side), but it does not include 
  details of any https requests that were rejected before reaching rails. (Possibly by nginx)
* Cloudtrail for the cluster includes a summary of request times, successes and failures, but not in depth info on what
  rails was doing at the time of the failure.

In order to get a full picture of the test results, we need to combine both sets of data. One way of doing this was
to exporting results for the appropriate timeframe and service from datadog into a CSV and from there into a 
spreadsheet. Results were grouped by url, with the number of requests, minimum time, maximum time, average time 
and total time.

This was then combined with the output from cloudwatch for the each of the tasks, given the JMeter summary of how many
requests failed in that same timeframe.

Insights were based on these values.

### Cleaning up when finished

* Delete the cluster `vita-jmeter-test` at https://us-east-1.console.aws.amazon.com/ecs/v2/clusters/vita-jmeter-test/services?region=us-east-1
* Delete the repository `vita-jmeter-test` at https://us-east-1.console.aws.amazon.com/ecr/private-registry/repositories?region=us-east-1
* Deregister task definitions `jmeter-test` at https://us-east-1.console.aws.amazon.com/ecs/v2/task-definitions?region=us-east-1
* Delete the namespace `vita-jmeter-test` at https://us-east-1.console.aws.amazon.com/cloudmap/home/namespaces?region=us-east-1


## References

 * https://www.linkedin.com/pulse/running-jmeter-test-aws-ecs-anees-mohammed/

