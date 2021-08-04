FactoryBot.define do
  factory :client_efile_security_information, class: Client::EfileSecurityInformation do
    device_id { "7BA1E530D6503F380F1496A47BEB6F33E40403D1" }
    user_agent { "GeckoFox" }
    browser_language { "en-US" }
    platform { "MacIntel" }
    timezone_offset { "+240" }
    client_system_time { "Mon Aug 02 2021 18:55:41 GMT-0400 (Eastern Daylight Time)" }
    ip_address { IPAddr.new("1.1.1.1") }
  end
end
