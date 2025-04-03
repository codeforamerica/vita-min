module JavascriptHelpers
  extend ActiveSupport::Concern

  def wait_until(time: Capybara.default_max_wait_time)
    Timeout.timeout(time) do
      until value = yield
        sleep(0.1)
      end
      value
    end
  end

  def wait_for_device_info(form_name)
    wait_until do
      device_id_input_element = page.find_all("input[name='state_file_#{form_name}_form[device_id]']", visible: false).last
      device_id_input_element.value.present?
    end
  end

end
