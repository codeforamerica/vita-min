class ActionView::TestCase::TestController
  def default_url_options(_options = {})
    { locale: I18n.default_locale, host: "test.host" }
  end
end

class ActionDispatch::Routing::RouteSet
  def default_url_options(_options = {})
    if Capybara.current_driver == Capybara.javascript_driver
      { locale: I18n.default_locale, host: "#{Capybara.server_host}:#{Capybara.server_port}" }
    else
      { locale: I18n.default_locale, host: "test.host" }
    end
  end
end
