Flipper.configure do |config|
  config.default do
    adapter = Flipper::Adapters::ActiveRecord.new
    Flipper.new(adapter)
  end
end

# Change this to Flipper.enable to test notification emails,
# then eventually delete it and the corresponding flag checks when notification
# emails are turned on in prod and running smoothly
Flipper.disable :state_file_notification_emails

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
    current_user.present? && current_user.admin? && current_user.email.include?("@codeforamerica.org")
  end
end