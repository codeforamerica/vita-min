# == Schema Information
#
# Table name: efile_security_informations
#
#  id                  :bigint           not null, primary key
#  browser_language    :string
#  client_system_time  :string
#  ip_address          :inet
#  platform            :string
#  recaptcha_score     :decimal(, )
#  timezone            :string
#  timezone_offset     :string
#  user_agent          :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  client_id           :bigint
#  device_id           :string
#  efile_submission_id :bigint
#
# Indexes
#
#  index_client_efile_security_informations_efile_submissions_id  (efile_submission_id)
#  index_efile_security_informations_on_client_id                 (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (efile_submission_id => efile_submissions.id)
#
FactoryBot.define do
  factory :efile_security_information do
    device_id { "7BA1E530D6503F380F1496A47BEB6F33E40403D1" }
    user_agent { "GeckoFox" }
    browser_language { "en-US" }
    platform { "MacIntel" }
    timezone_offset { "+240" }
    client_system_time { "Mon Aug 02 2021 18:55:41 GMT-0400 (Eastern Daylight Time)" }
    ip_address { IPAddr.new("1.1.1.1") }
    timezone { "America/New_York" }
    recaptcha_score { 0.9 }
  end
end
