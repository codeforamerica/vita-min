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

While running JMeter from a local developer machine is possible (and necessary for developing test plans), testing production-like environments must be done within AWS to not trigger anti-DDOS protections.

Use these instructions to create a docker image that can be deployed to Fargate / ECS for testing production-like environments.

 * Download docker from https://docker.com
 * Cd into the `jmeter_tests/` directory, and create an image with `docker build -t jmeter_test .`
 * Make sure your local AWS config (in $HOME/.aws) contains your credentials for AWS.
 * Create a Repository in Amazon Elastic Container Registry (ECR). I created `tim-jmeter-test` in https://us-east-1.console.aws.amazon.com/ecr/private-registry/repositories?region=us-east-1
 * Push your docker image to your Repository. (Click "View Push commands" at https://us-east-1.console.aws.amazon.com/ecr/private-registry/repositories?region=us-east-1)
 * Create a fargate cluster at https://us-east-1.console.aws.amazon.com/ecs/v2/clusters?region=us-east-1 (I created `tim-jmeter-test`)
 * Create a task to run your docker image on your cluster. For "Compute Options", I chose "Launch Type" with "FARGATE".
   My application type was "Task", and "jmeter-test" was the "Family". For "Networking", I chose the "tax-benefits-dashboards-vpc" with all subnets.
   I chose the "default" and "VPN Security Group" Security Groups. I enabled a public IP.

### References

 * https://www.linkedin.com/pulse/running-jmeter-test-aws-ecs-anees-mohammed/

