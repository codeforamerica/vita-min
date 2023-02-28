# == Schema Information
#
# Table name: assignment_emails
#
#  id                :bigint           not null, primary key
#  assigned_at       :datetime
#  mailgun_status    :string           default("sending")
#  sent_at           :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  assigned_user_id  :bigint
#  assigning_user_id :bigint
#  message_id        :string
#  tax_return_id     :bigint           not null
#
# Indexes
#
#  index_assignment_emails_on_assigned_user_id   (assigned_user_id)
#  index_assignment_emails_on_assigning_user_id  (assigning_user_id)
#  index_assignment_emails_on_tax_return_id      (tax_return_id)
#
# Foreign Keys
#
#  fk_rails_...  (assigned_user_id => users.id)
#  fk_rails_...  (assigning_user_id => users.id)
#  fk_rails_...  (tax_return_id => tax_returns.id)
#
FactoryBot.define do
  factory :assignment_email do
    assigned_at { "2023-02-27 15:59:27" }
    assigned_user { build(:user) }
    assigning_user { build(:user) }
    tax_return { build(:gyr_tax_return) }
  end
end
