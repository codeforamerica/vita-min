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
  # EVENT_TYPES = ["read_bank_account_info", "read_ssn_itin", "viewed_document", "viewed_call_page_ssn_itin", "read_ip_pin", "downloaded_submission_bundle"]
  belongs_to :intake, polymorphic: true
  # validate :valid_event_type
  # remove user agent and device type

  private

  # def valid_event_type
  #   errors.add(:event_type, "Not a valid access log event") unless EVENT_TYPES.include?(event_type)
  # end
end
