# == Schema Information
#
# Table name: ticket_statuses
#
#  id            :bigint           not null, primary key
#  intake_status :string           not null
#  return_status :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  intake_id     :bigint
#  ticket_id     :integer
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
    intake_status { EitcZendeskInstance::INTAKE_STATUS_IN_PROGRESS }
    return_status { EitcZendeskInstance::RETURN_STATUS_IN_PROGRESS }
  end
end
