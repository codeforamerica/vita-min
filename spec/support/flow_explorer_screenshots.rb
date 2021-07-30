class FlowExplorerScreenshots
  def self.hook!(config)
    require 'mini_magick'

    Capybara::Session.class_exec do
      capybara_visit = instance_method(:visit)

      define_method :visit do |*args|
        capybara_visit.bind(self).call(*args)
        FlowExplorerScreenshots.create_flow_explorer_screenshot
      end
    end

    Capybara::Node::Actions.module_exec do
      [:click_on, :click_button, :click_link].each do |capybara_method|
        orig = instance_method(capybara_method)
        define_method(capybara_method) do |*args|
          # Allow click_link to be called in create_flow_explorer_screenshot without recursing forever
          no_screenshot = args.last.is_a?(Hash) && args.last.dig(:no_screenshot)
          args.pop if no_screenshot
          orig.bind(self).call(*args)
          FlowExplorerScreenshots.create_flow_explorer_screenshot unless no_screenshot
        end
      end
    end
  end

  private

  def self.create_flow_explorer_screenshot
    recognized_path = Rails.application.routes.recognize_path(Capybara.page.current_path)
    controller_class = (recognized_path[:controller].camelize + 'Controller').constantize rescue nil
    if controller_class && recognized_path[:action].to_sym == :edit
      if ENV['FLOW_EXPLORER_LOCALE'].present?
        create_controller_card_screenshot(controller_class, locale: ENV['FLOW_EXPLORER_LOCALE'].to_sym)
      else
        create_controller_card_screenshot(controller_class, locale: :en, switch_locale: true)
        create_controller_card_screenshot(controller_class, locale: :es, switch_locale: true)
      end
    end
  end

  def self.create_controller_card_screenshot(controller_class, locale:, switch_locale: false)
    FileUtils.mkdir_p(Rails.root.join("public/assets/flow_screenshots/#{locale}"))
    screenshot_path = Rails.root.join("public/assets/flow_screenshots/#{locale}/#{controller_class}.png")
    if File.exist?(screenshot_path) && File.mtime(screenshot_path) > 3.hours.ago
      return
    end

    if locale == :es && switch_locale
      Capybara.page.find('.main-header').click_link("Español", no_screenshot: true)
    end

    card_rect = Capybara.page.evaluate_script(<<~SIZE_JS)
      document.querySelector('main').getBoundingClientRect();
    SIZE_JS

    Capybara.page.save_screenshot screenshot_path

    image = MiniMagick::Image.new(screenshot_path) # .new operates on the image in place
    padding = 30
    image.crop "#{card_rect['width'] + padding * 2}x#{card_rect['height'] + padding * 2}+#{card_rect['x'] - padding}+#{card_rect['y'] - padding}"
    puts "Saved new screenshot to #{screenshot_path}"

    if locale == :es && switch_locale
      Capybara.page.find('.main-header').click_link('English', no_screenshot: true)
    end
  end
end
