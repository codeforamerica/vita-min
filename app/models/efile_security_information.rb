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
class EfileSecurityInformation < ApplicationRecord
  belongs_to :client
  validates_presence_of :device_id,
                     :user_agent,
                     :browser_language,
                     :platform,
                     :timezone_offset,
                     :client_system_time,
                     :ip_address
  # storing client_system_time as a string and then transforming it into DateTime for the return_header1040
  # b/c the db would record the date in UTC and we would lose the client's timezone
  def client_system_datetime
    return nil unless client_system_time.present?

    begin
      DateTime.parse(client_system_time)
    rescue ArgumentError
      length_limited_datetime = client_system_time.split(" (").first
      DateTime.parse(length_limited_datetime)
    end
  end
end
