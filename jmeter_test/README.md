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

### Examples

* `jmeter_test -t fyst_az_standard_usage` : Run `fyst_az_standard_usage` plan against dev
* `jmeter_test -t fyst_az_standard_usage -e staging` : Run `fyst_az_standard_usage` plan against staging
* `jmeter_test -t fyst_az_standard_usage -g` : Open `fyst_az_standard_usage` plan in GUI
