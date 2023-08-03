# == Schema Information
#
# Table name: state_efile_submissions
#
#  id                      :bigint           not null, primary key
#  intake_type             :string           not null
#  last_checked_for_ack_at :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  intake_id               :bigint           not null
#  irs_submission_id       :string
#
# Indexes
#
#  index_state_efile_submissions_on_intake  (intake_type,intake_id)
#
FactoryBot.define do
  factory :state_efile_submission do
    irs_submission_id { "MyString" }
    last_checked_for_ack_at { "2023-08-03 15:05:30" }
    intake { nil }
  end
end
