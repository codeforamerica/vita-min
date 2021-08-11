# == Schema Information
#
# Table name: access_logs
#
#  id          :bigint           not null, primary key
#  event_type  :string           not null
#  ip_address  :inet
#  record_type :string           not null
#  user_agent  :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  record_id   :bigint           not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_access_logs_on_record_type_and_record_id  (record_type,record_id)
#  index_access_logs_on_user_id                    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AccessLog < ApplicationRecord
  EVENT_TYPES = ["read_bank_account_info", "read_ssn_itin", "viewed_document", "viewed_call_page_ssn_itin", "read_ip_pin", "downloaded_submission_bundle"]
  belongs_to :record, polymorphic: true
  belongs_to :user
  validate :valid_event_type

  private

  def valid_event_type
    errors.add(:event_type, "Not a valid access log event") unless EVENT_TYPES.include?(event_type)
  end
end
