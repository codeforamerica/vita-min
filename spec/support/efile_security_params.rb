RSpec.configure do |config|
  config.before(:each) do |example|
    if example.metadata[:efile_security_params]
      allow(Rails.application.config).to receive(:efile_security_information_for_testing).and_return(
        {
          device_id: "7BA1E530D6503F380F1496A47BEB6F33E40403D1",
          user_agent: "GeckoFox",
          browser_language: "en-US",
          platform: "iPad",
          timezone_offset: "+240",
          client_system_time: "2021-07-28T21:21:32.306Z"
        }
      )
    end
  end
end
