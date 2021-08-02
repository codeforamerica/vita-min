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
FactoryBot.define do
  factory :client_efile_security_informations do

  end
end
