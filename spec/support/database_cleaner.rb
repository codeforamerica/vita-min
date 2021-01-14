RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:deletion, except: %w(spatial_ref_sys))
  end
end

