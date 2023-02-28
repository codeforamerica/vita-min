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
class AssignmentEmail < ApplicationRecord
  belongs_to :assigned_user, class_name: "User"
  belongs_to :assigning_user, class_name: "User"
  belongs_to :tax_return
end
