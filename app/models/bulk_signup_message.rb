# == Schema Information
#
# Table name: bulk_signup_messages
#
#  id                  :bigint           not null, primary key
#  message             :text             not null
#  message_type        :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  signup_selection_id :bigint           not null
#  user_id             :bigint           not null
#
# Indexes
#
#  index_bulk_signup_messages_on_signup_selection_id  (signup_selection_id)
#  index_bulk_signup_messages_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (signup_selection_id => signup_selections.id)
#  fk_rails_...  (user_id => users.id)
#
class BulkSignupMessage < ApplicationRecord
  enum message_type: { sms: 1, email: 2 }

  belongs_to :user
  belongs_to :signup_selection

  validates :message, presence: true

  # TODO make these real
  def status
    "sending"
  end

  def pending_to_send
    signup_selection.id_array.length
  end
end
