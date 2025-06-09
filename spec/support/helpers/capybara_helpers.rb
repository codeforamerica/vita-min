module CapybaraHelpers
  # Wraps the checks on a particular page and retries a specified number of
  # times with a specified sleep in between
  #
  # @param [Float] sleep_time
  # @param [Integer] retries
  # @yield [nil] Invokes the block passed and then retries on certain failures
  def page_change_block(sleep_time = 0.1, retries: 2, &block)
    retry_count = 0
    begin
      yield block
    rescue Selenium::WebDriver::Error::WebDriverError,
      Capybara::ElementNotFound,
      UncaughtThrowError,
      RSpec::Expectations::ExpectationNotMetError => e
      puts "Caught #{e.class} - #{e.message}"
      puts "Failed attempt, sleeping #{sleep_time} seconds then retrying..."
      sleep sleep_time
      retry_count += 1
      retry_count <= retries ? retry : raise
    end
  end
end
