module FeatureHelpers
  extend ActiveSupport::Concern

  def screenshot_after
    yield

    if @metadata_screenshot
      @screenshot_index = defined?(@screenshot_index) ? @screenshot_index + 1 : 1
      example_text, spec_path = inspect.match(/"(.*)" \(\.\/spec\/features\/(.*)_spec\.rb/)[1, 2]

      screenshot_name = "#{format('%02d', @screenshot_index)}|#{spec_path}|#{example_text.parameterize}|#{current_path.parameterize}"
      page.percy_snapshot(screenshot_name)
    end
  end
end
