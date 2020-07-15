# == Schema Information
#
# Table name: client_efforts
#
#  id              :bigint           not null, primary key
#  effort_type     :integer          not null
#  made_at         :datetime         not null
#  responded_to_at :datetime
#  response_type   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  intake_id       :bigint           not null
#  ticket_id       :bigint           not null
#
# Indexes
#
#  index_client_efforts_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#
FactoryBot.define do
  factory :client_effort do
    intake
    ticket_id { 12345678 }
    effort_type { "emailed_support" }
    made_at { DateTime.now }
  end
end
