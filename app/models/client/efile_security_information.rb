# == Schema Information
#
# Table name: client_efile_security_informations
#
#  id                 :bigint           not null, primary key
#  browser_language   :string           not null
#  client_system_time :string           not null
#  ip_address         :inet
#  platform           :string           not null
#  timezone_offset    :string           not null
#  user_agent         :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  client_id          :bigint           not null
#  device_id          :string           not null
#
# Indexes
#
#  index_client_efile_security_informations_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
class Client::EfileSecurityInformation < ApplicationRecord
  belongs_to :client

  # storing client_system_time as a string and then transforming it into DateTime for the return_header1040
  # b/c the db would record the date in UTC and we would lose the client's timezone
  def client_system_datetime
    return nil unless client_system_time.present?

    DateTime.parse(client_system_time)
  end
end
