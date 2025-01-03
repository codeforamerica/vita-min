# == Schema Information
#
# Table name: state_file_archived_intake_access_logs
#
#  id                             :bigint           not null, primary key
#  details                        :jsonb
#  event_type                     :integer
#  ip_address                     :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  state_file_archived_intakes_id :bigint
#
# Indexes
#
#  idx_on_state_file_archived_intakes_id_e878049c06  (state_file_archived_intakes_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_file_archived_intakes_id => state_file_archived_intakes.id)
#
FactoryBot.define do
  factory :state_file_archived_intake_access_log do
    
  end
end
