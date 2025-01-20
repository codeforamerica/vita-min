# == Schema Information
#
# Table name: state_file_archived_intake_requests
#
#  id                            :bigint           not null, primary key
#  email_address                 :string
#  failed_attempts               :integer          default(0), not null
#  ip_address                    :string
#  locked_at                     :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  state_file_archived_intake_id :bigint
#
# Indexes
#
#  idx_on_state_file_archived_intake_id_7dd0f99380  (state_file_archived_intake_id)
#
FactoryBot.define do
  factory :state_file_archived_intake_request do
    email_address { "geddy_lee@gmail.com" }
    failed_attempts { 0 }
    locked_at { nil }

    trait :locked do
      locked_at { 5.minutes.ago }
    end
  end
end
