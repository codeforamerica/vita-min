# == Schema Information
#
# Table name: outgoing_text_messages
#
#  id            :bigint           not null, primary key
#  body          :string           not null
#  sent_at       :datetime         not null
#  twilio_sid    :string
#  twilio_status :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  case_file_id  :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_outgoing_text_messages_on_case_file_id  (case_file_id)
#  index_outgoing_text_messages_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (case_file_id => case_files.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :outgoing_text_message do
    case_file
    user
    body { "wyd" }
    sequence(:sent_at) { |n| DateTime.new(2020, 9, 2, 15, 1, 30) + n.minutes }
  end
end
