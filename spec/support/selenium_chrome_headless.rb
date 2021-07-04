# From capybara-3.35.3/lib/capybara/registrations/drivers.rb:30
# can be replaced with `driven_by :selenium, using: :headless_chrome`
# someday if we move from /features/ to /system/
# like in https://github.com/codeforamerica/gcf-backend/blob/main/spec/support/system_tests.rb#L34
Capybara.register_driver :selenium_chrome_headless do |app|
  version = Capybara::Selenium::Driver.load_selenium
  options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument('--headless')
    opts.add_argument('--disable-gpu') if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.add_argument('--disable-site-isolation-trials')

    # Ensure screenshots taken on retina displays aren't 2x the browser resolution
    # (this causes an issue with the Flow Explorer screenshots, which try to crop
    # the full page screenshot based on coordinate values from JavaScript land)
    opts.add_argument('--force-device-scale-factor=1')
  end

  Capybara::Selenium::Driver.new(app, **Hash[:browser => :chrome, options_key => browser_options])
end
