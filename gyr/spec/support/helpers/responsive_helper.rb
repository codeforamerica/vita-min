module ResponsiveHelper
  def resize_window_to_flattened_window
    resize_window(1200, 480)
  end

  def resize_window_to_mobile
    resize_window(375, 627) # apple iPhone 6
  end

  def resize_window_to_tablet
    resize_window(960, 640)
  end

  def resize_window_to_desktop
    resize_window(1024, 768)
  end

  private

  def resize_window(width, height)
    case Capybara.current_driver
    when :selenium_chrome_headless
      Capybara.current_session.driver.browser.manage.window.resize_to(width, height)
    when :webkit
      handle = Capybara.current_session.driver.current_window_handle
      Capybara.current_session.driver.resize_window_to(handle, width, height)
    else
      raise NotImplementedError, "resize_window is not supported for #{Capybara.current_driver} driver"
    end
  end
end