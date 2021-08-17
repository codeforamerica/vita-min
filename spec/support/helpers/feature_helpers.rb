module FeatureHelpers
  extend ActiveSupport::Concern

  def screenshot_after
    yield

    if @metadata_screenshot
      example_text, spec_path = inspect.match(/"(.*)" \(\.\/spec\/features\/(.*)_spec\.rb/)[1, 2]
      page.percy_snapshot("#{spec_path}/#{example_text.parameterize}#{current_path}")
    end
  end
end
