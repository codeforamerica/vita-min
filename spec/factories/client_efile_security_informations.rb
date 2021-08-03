# == Schema Information
#
# Table name: client_efile_security_informations
#
#  id                 :bigint           not null, primary key
#  browser_language   :string
#  client_system_time :string
#  ip_address         :inet
#  platform           :string
#  timezone_offset    :string
#  user_agent         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  client_id          :bigint
#  device_id          :string
#
# Indexes
#
#  index_client_efile_security_informations_on_client_id  (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#
FactoryBot.define do
  factory :client_efile_security_informations do

  end
end
