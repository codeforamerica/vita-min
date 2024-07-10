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

`jmeter_test -t <TEST_PLAN> <-e <ENVIRONMENT>> <-g>`

## Examples

 * `jmeter_test/jmeter_test -t fyst_az_5_minute_stress_test` : Run `fyst_az_5_minute_stress_test` plan against dev
 * `jmeter_test/jmeter_test -t fyst_az_5_minute_stress_test -e staging` : Run `fyst_az_5_minute_stress_test` plan against staging
 * `jmeter_test/jmeter_test -t fyst_az_5_minute_stress_test -g` : Open `fyst_az_5_minute_stress_test` plan in GUI


## Running in AWS

Running JMeter from a developer machine is possible, though 
This will create a docker image that can be deployed to Fargate / ECS.

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

