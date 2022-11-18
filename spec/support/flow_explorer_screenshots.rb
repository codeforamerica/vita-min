class FlowExplorerScreenshots
  def self.hook!(config)
    require 'mini_magick'

    Capybara::Session.class_exec do
      orig = instance_method(:visit)
      define_method :visit do |*args|
        # Allow visit to be called in create_flow_explorer_screenshot without recursing forever
        no_screenshot = args.last.is_a?(Hash) && args.last.dig(:no_screenshot)
        args.pop if no_screenshot
        orig.bind(self).call(*args)
        FlowExplorerScreenshots.new.create_flow_explorer_screenshot unless no_screenshot
      end
    end

    Capybara::Node::Actions.module_exec do
      [:click_on, :click_button, :click_link].each do |capybara_method|
        orig = instance_method(capybara_method)
        define_method(capybara_method) do |*args|
          orig.bind(self).call(*args)

          # Capybara only allows calling .switch_to_window (which is used to capture the spanish screenshots)
          # if we're not in a `within` block
          if Capybara.current_scope.is_a?(Capybara::Node::Document)
            FlowExplorerScreenshots.new.create_flow_explorer_screenshot
          end
        end
      end
    end
  end

  def initialize
    recognized_path = Rails.application.routes.recognize_path(Capybara.page.current_path)
    @controller_class = (recognized_path[:controller].camelize + 'Controller').constantize rescue nil
    @controller_action = recognized_path[:action].to_sym
  end

  def create_flow_explorer_screenshot
    if @controller_class&.flow_explorer_actions&.include?(@controller_action)
      if ENV['FLOW_EXPLORER_LOCALE'].present?
        create_controller_card_screenshot(locale: ENV['FLOW_EXPLORER_LOCALE'].to_sym)
      else
        create_controller_card_screenshot(locale: :en, switch_locale: true)
        create_controller_card_screenshot(locale: :es, switch_locale: true)
      end
    end
  end

  private

  def screenshot_filename
    FlowsController::DecoratedController.new(@controller_class, @controller_action).screenshot_filename
  end

  def create_controller_card_screenshot(locale:, switch_locale: false)
    FileUtils.mkdir_p(Rails.root.join("public/assets/flow_screenshots/#{locale}"))
    screenshot_path = Rails.root.join("public/assets/flow_screenshots/#{locale}/#{screenshot_filename}")
    if File.exist?(screenshot_path) && File.mtime(screenshot_path) > 3.hours.ago
      return
    end

    if locale == :es && switch_locale
      link = Capybara.page.evaluate_script("document.querySelector('#locale_switcher_#{locale}').href")
      if Capybara.windows.count == 1
        Capybara.open_new_window
      end
      Capybara.switch_to_window(Capybara.windows.last)
      Capybara.visit(link, no_screenshot: true)
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
      Capybara.switch_to_window(Capybara.windows.first)
    end
  end
end
