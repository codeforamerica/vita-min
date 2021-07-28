# == Schema Information
#
# Table name: efile_security_informations
#
#  id                 :bigint           not null, primary key
#  client_system_time :string
#  ip_address         :inet
#  language           :string
#  platform           :string
#  timezone_offset    :string
#  user_agent         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  device_id          :string
#
class EfileSecurityInformation < ApplicationRecord
end
