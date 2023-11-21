# == Schema Information
#
# Table name: state_file_efile_device_infos
#
#  id          :bigint           not null, primary key
#  event_type  :string
#  intake_type :string           not null
#  ip_address  :inet
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  device_id   :string
#  intake_id   :bigint           not null
#
# Indexes
#
#  index_state_file_efile_device_infos_on_intake  (intake_type,intake_id)
#
class StateFileEfileDeviceInfo < ApplicationRecord
  belongs_to :intake, polymorphic: true

  EVENT_TYPES = %w[initial_creation submission].freeze
  validate :valid_event_type

  private

  def valid_event_type
    errors.add(:event_type, "Not a valid access log event") unless EVENT_TYPES.include?(event_type)
  end
end
