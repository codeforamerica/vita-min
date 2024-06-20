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

This will create a docker image that can be deployed to Fargate / ECS using serverless.

 * Download docker from https://docker.com
 * From `jmeter_tests/` Create an image with `docker build -t jmeter_test .`
 * Make sure your local AWS settings are in place.
 * Deploy with `sls deploy`

### References

 * https://www.linkedin.com/pulse/running-jmeter-test-aws-ecs-anees-mohammed/
 * https://www.serverless.com/plugins/serverless-fargate

