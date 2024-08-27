# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

require "spec_helper"
require "capybara/rails"
require "capybara/rspec"
require "selenium/webdriver"
require "percy/capybara"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
Dir[Rails.root.join("lib/strategies/**/*.rb")].each { |f| require f }

# Set CHROME=true to run specs with a visible Chrome window
if ENV.fetch("CHROME", false)
  Capybara.javascript_driver = :selenium_chrome
else
  Capybara.javascript_driver = :selenium_chrome_headless
end

Capybara.default_max_wait_time = 5
Capybara.server = :puma, { Silent: true }
Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i
if ENV['DOCKER']
  Capybara.server_host = "rails"
else
  Capybara.server_host = "0.0.0.0"
end
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"

Capybara::Session.class_exec do
  capybara_visit = instance_method(:fill_in)

  def filling_in_ssn_without_dashes(args)
    args[0].is_a?(String) &&
      args[0].downcase.include?('ssn') &&
      !args[0].include?('DependentSSN') &&
      !args[0].downcase.include?('last 4') &&
      !args[0].downcase.include?('4 últimos') &&
      !args[1][:with].to_s.match(/\d{3}-\d{2}-\d{4}/)
  end

  define_method :fill_in do |*args|
    if filling_in_ssn_without_dashes(args)
      raise ArgumentError.new("Looks like you're trying to fill_in '#{args[0]}' with '#{args[1][:with]}' -- SSN fields must include dashes in tests or else the test will flake")
    end
    capybara_visit.bind(self).call(args[0], **args[1])
  end
end

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil # Set to nil to prevent RSpec from doing truncation
  end
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include Rails.application.routes.url_helpers
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.include Warden::Test::Helpers
  config.include ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ChannelHelpers, type: :channel
  config.include ActiveSupport::Testing::TimeHelpers
  config.include NavigationHelpers
  config.include FeatureHelpers, type: :feature
  config.include ResponsiveHelper, type: :feature
  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.before(:each) do
    stub_const('Fraud::Score::HOLD_THRESHOLD', 1000)
    stub_const('Fraud::Score::RESTRICT_THRESHOLD', 1000)
    stub_request(:post, /.*api\.twilio\.com.*/).to_return(status: 200, body: "", headers: {})
    stub_request(:get, /.*lookups\.twilio\.com.*/).to_return(status: 200, body: "{}", headers: {})
    stub_request(:post, "https://api.mixpanel.com/track").to_return(status: 200, body: "", headers: {})
    # Stub required credentials to prevent need for RAILS_MASTER_KEY in test
    @test_environment_credentials = {
      duplicate_hashing_key: "secret",
      previous_duplicate_hashing_key: "",
      irs: {
        efin: '123456',
        sin: '11111111'
      },
      intercom: {
        intercom_access_token: "fake_access_token",
        secure_mode_secret_key: "a-fake-key-to-use-for-hashing",
        statefile_secure_mode_secret_key: "a-fake-key-to-use-for-hashing"
      }
    }
    allow(Rails.application).to receive(:credentials).and_return(@test_environment_credentials)
    allow_any_instance_of(ApplicationController).to receive(:open_for_ctc_intake?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:open_for_ctc_login?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:open_for_ctc_read_write?).and_return(true)
    allow(Rails.configuration).to receive(:end_of_login).and_return(2.days.from_now)
    # Stub valid_email2's network-dependent functionality per https://github.com/micke/valid_email2
    allow_any_instance_of(ValidEmail2::Address).to receive(:valid_mx?) { true }
    # Stub DNS implementation to avoid network calls from test suite; valid_email2 uses this
    fake_dns = instance_double(Resolv::DNS)
    allow(fake_dns).to receive(:open) { raise StandardError, "Cannot use DNS from test suite" }
    allow(fake_dns).to receive(:close)
    allow(Resolv::DNS).to receive(:new).and_return(fake_dns)
    OmniAuth.config.test_mode = true
  end

  if config.filter.rules[:flow_explorer_screenshot]
    FlowExplorerScreenshots.hook!(config)
  end

  if ENV.include? "ALLOWED_SCHEMAS"
    allowed_schemas = ENV["ALLOWED_SCHEMAS"].split(",").map(&:strip)
    config.filter_run_excluding required_schema: lambda { |required_schema|
      !allowed_schemas.include? required_schema
    }
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec.configure do |config|
  config.before(:all, type: :feature) do |_example|
    Seeder.load_fraud_indicators
  end

  config.before(type: :feature) do |example|
    if config.filter.rules[:flow_explorer_screenshot]
      example.metadata[:js] = true
      Capybara.current_driver = Capybara.javascript_driver
      Capybara.page.current_window.resize_to(2000, 4000)
    end

    unless Capybara.current_driver == Capybara.javascript_driver
      allow(Rails.application.config).to receive(:efile_security_information_for_testing).and_return(
        {
          device_id: "7BA1E530D6503F380F1496A47BEB6F33E40403D1",
          user_agent: "GeckoFox",
          browser_language: "en-US",
          platform: "iPad",
          timezone_offset: "+240",
          client_system_time: "2021-07-28T21:21:32.306Z",
          timezone: "America/New_York"
        }
      )
    end
  end

  config.before(:each) do
    unless Capybara.current_driver == Capybara.javascript_driver
      Flipper.instance = Flipper.new(Flipper::Adapters::Memory.new)
    end
    ExperimentService.ensure_experiments_exist_in_database
  end

  config.before(type: :feature, js: true) do |example|
    @metadata_screenshot = example.metadata[:screenshot]
  end

  config.after(type: :feature, js: true) do |example|
    if example.exception
      begin
        timestamp = Time.zone.now.strftime("%Y_%m_%d-%H_%M_%S")
        filename = "failure_#{example.location.gsub(/[^a-z0-9]/i, '_')}-#{timestamp}.png"
        screenshot_path = if ENV['CIRCLECI']
          File.join("/tmp", "failure_screenshots", filename)
        else
          Rails.root.join("tmp", "failure_screenshots", filename)
        end

        browser_console_logs = page.driver.browser.logs.get(:browser)
        if browser_console_logs.length > 0
          STDERR.puts "\n\nvv During this test failure, there was some output in the browser's console vv"
          STDERR.puts browser_console_logs.map(&:message).join("\n")
          STDERR.puts "^^ ^^"
        end
        STDERR.puts "Saved failed test screenshot to #{page.save_screenshot(screenshot_path)}"
      rescue
        # Don't let any errors from printing the errors cause more errors
      end
    end
  end
end
