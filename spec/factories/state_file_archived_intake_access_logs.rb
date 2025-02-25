# == Schema Information
#
# Table name: state_file_archived_intake_access_logs
#
#  id                                    :bigint           not null, primary key
#  details                               :jsonb
#  event_type                            :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  state_file_archived_intake_id         :bigint
#  state_file_archived_intake_request_id :bigint
#
# Indexes
#
#  idx_on_state_file_archived_intake_id_a016b5cab5  (state_file_archived_intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_file_archived_intake_id => state_file_archived_intakes.id)
#  fk_rails_...  (state_file_archived_intake_request_id => state_file_archived_intake_requests.id)
#
FactoryBot.define do
  factory :state_file_archived_intake_access_log do
    
  end
end
