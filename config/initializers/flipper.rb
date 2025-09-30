Flipper.configure do |config|
  config.default do
    adapter = Flipper::Adapters::ActiveRecord.new
    Flipper.new(adapter)
  end
end

# This structure is borrowed from https://github.com/department-of-veterans-affairs/vets-api/blob/247c84c0226d4cc90477b96a46107c6bace62bd5/config/initializers/flipper.rb
# Make sure that each feature we reference in code is present in the UI, as long as we have a Database already
begin
  Flipper.disable :extension_period unless Flipper.exist?(:extension_period)
  Flipper.disable :get_your_pdf unless Flipper.exist?(:get_your_pdf)
  Flipper.disable :hub_dashboard unless Flipper.exist?(:hub_dashboard)
  Flipper.disable :hub_email_notifications unless Flipper.exist?(:hub_email_notifications)
  Flipper.disable :income_review_v2 unless Flipper.exist?(:income_review_v2)
  Flipper.disable :show_retirement_ui unless Flipper.exist?(:show_retirement_ui)
  Flipper.disable :sms_notifications unless Flipper.exist?(:sms_notifications)
  Flipper.disable :use_pundit unless Flipper.exist?(:use_pundit)
  Flipper.disable :immediate_df_closure unless Flipper.exist?(:immediate_df_closure)
  if Rails.env.heroku? || Rails.env.demo?
    Flipper.disable :prevent_duplicate_accepted_statefile_submissions unless Flipper.exist?(:prevent_duplicate_accepted_statefile_submissions)
    Flipper.disable :prevent_duplicate_ssn_messaging unless Flipper.exist?(:prevent_duplicate_ssn_messaging)
  else
    Flipper.enable :prevent_duplicate_accepted_statefile_submissions unless Flipper.exist?(:prevent_duplicate_accepted_statefile_submissions)
    Flipper.enable :prevent_duplicate_ssn_messaging unless Flipper.exist?(:prevent_duplicate_ssn_messaging)
  end
rescue StandardError
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
