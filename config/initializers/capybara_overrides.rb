class Capybara::Window
  def resize_to(width, height, override: false)
    return super(width, height) unless override

    wait_for_stable_size(10.seconds) { @driver.resize_window_to(handle, width, height) }
  end
end
