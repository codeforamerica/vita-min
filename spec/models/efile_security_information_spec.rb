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
require 'rails_helper'

RSpec.describe EfileSecurityInformation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
