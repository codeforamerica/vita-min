def upload_file(field, file)
  if Capybara.current_driver == Capybara.javascript_driver
    # File automatically uploads on attach when there's JavaScript around
    attach_file(field, file, make_visible: true)
  else
    attach_file(field, file)
    click_on "Upload"
  end
end
