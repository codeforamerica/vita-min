# == Schema Information
#
# Table name: bulk_signup_messages
#
#  id                  :bigint           not null, primary key
#  message             :text             not null
#  message_type        :integer          not null
#  subject             :text
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
FactoryBot.define do
  factory :bulk_signup_message do
    signup_selection { build(:signup_selection) }
    user { build(:user) }
    subject { message_type == 'email' ? "hello to you" : nil }
    message { "We are now open" }
    message_type { "email" }
  end
end
