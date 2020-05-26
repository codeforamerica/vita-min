RSpec.configure do |config|
  config.around do |example|
    default_locale = I18n.locale
    example.run
    I18n.locale = default_locale
  end
end
