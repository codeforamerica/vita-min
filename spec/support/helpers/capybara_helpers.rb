module CapybaraHelpers
  # Wraps the checks on a particular page and retries a specified number of
  # times with a specified sleep in between. It is important to know that all
  # steps of the block must be fine to repeat from the top on retry. For
  # example, make sure that there are no page transitions within the block or
  # else if it fails on the next page, it will go back to the top which will now
  # fail due to being the wrong page.
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

  def page_change_check(input, sleep_time: 0.1, path: false, retries: 2)
    retry_count = 0
    begin
      if path
        expect(page).to have_current_path(input)
      else
        expect(page).to have_text(input)
      end
    rescue Selenium::WebDriver::Error::WebDriverError,
      Capybara::ElementNotFound,
      RSpec::Expectations::ExpectationNotMetError => e
      puts "Caught #{e.class} - #{e.message}"
      puts "Failed attempt for `#{input}`, sleeping #{sleep_time} seconds then retrying..."
      sleep sleep_time
      retry_count += 1
      retry_count <= retries ? retry : raise
    end
  end
end
