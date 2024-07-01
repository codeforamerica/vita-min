Flipper.configure do |config|
  config.default do
    adapter = Flipper::Adapters::ActiveRecord.new
    Flipper.new(adapter)
  end
end

# This structure is borrowed from https://github.com/department-of-veterans-affairs/vets-api/blob/247c84c0226d4cc90477b96a46107c6bace62bd5/config/initializers/flipper.rb
# Make sure that each feature we reference in code is present in the UI, as long as we have a Database already
begin
  Flipper.disable :sms_notifications unless Flipper.exist?(:sms_notifications)
  Flipper.disable :hub_dashboard unless Flipper.exist?(:hub_dashboard)
rescue
  # make sure we can still run rake tasks before table has been created
  nil
end

Flipper::UI.configure do |config|
  # Defaults to false. Set to true to show feature descriptions on the list
  # page as well as the view page.
  config.show_feature_description_in_list = true

  if Rails.env.production?
    config.banner_text = 'Production Environment'
    config.banner_class = 'danger'
  elsif Rails.env.demo?
    config.banner_text = 'Demo Environment'
    config.banner_class = 'warning'
  elsif Rails.env.development?
    config.banner_text = 'Dev Environment'
    config.banner_class = 'info'
  elsif Rails.env.heroku?
    config.banner_text = 'Heroku Environment'
    config.banner_class = 'info'
  end
end

class CanAccessFlipperUI
  def self.matches?(request)
    return true if Rails.env.development? || Rails.env.heroku?
    current_user = request.env['warden'].user
    Ability.new(current_user).can?(:manage, :flipper_dashboard)
  end
end
