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
class OutgoingTextMessage < ApplicationRecord
  belongs_to :case_file
  belongs_to :user
  validates_presence_of :body
  validates_presence_of :sent_at
end
