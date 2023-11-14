# == Schema Information
#
# Table name: efile_device_infos
#
#  id          :bigint           not null, primary key
#  device_type :integer          default(0), not null
#  intake_type :string           not null
#  ip_address  :string
#  ip_port_num :string
#  ipts        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  device_id   :string
#  intake_id   :bigint           not null
#
# Indexes
#
#  index_efile_device_infos_on_intake  (intake_type,intake_id)
#
class EfileDeviceInfo < ApplicationRecord
  belongs_to :intake, polymorphic: true

end
