# == Schema Information
#
# Table name: incoming_text_messages
#
#  id                :bigint           not null, primary key
#  body              :string           not null
#  from_phone_number :string           not null
#  received_at       :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  case_file_id      :bigint           not null
#
# Indexes
#
#  index_incoming_text_messages_on_case_file_id  (case_file_id)
#
# Foreign Keys
#
#  fk_rails_...  (case_file_id => case_files.id)
#
FactoryBot.define do
  factory :incoming_text_message do
    case_file
    body { "nothin" }
    from_phone_number { "14155537865" }
    sequence(:received_at) { |n| DateTime.new(2020, 9, 2, 15, 1, 30) + n.minutes }
  end
end
