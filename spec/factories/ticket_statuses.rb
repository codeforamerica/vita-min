# == Schema Information
#
# Table name: ticket_statuses
#
#  id              :bigint           not null, primary key
#  eip_status      :string
#  intake_status   :string
#  return_status   :string
#  verified_change :boolean          default(TRUE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  intake_id       :bigint
#  ticket_id       :integer
#
# Indexes
#
#  index_ticket_statuses_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#
FactoryBot.define do
  factory :ticket_status do
    intake
  end
end
