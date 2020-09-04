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
class IncomingTextMessage < ApplicationRecord
  belongs_to :case_file
  validates_presence_of :body
  validates_presence_of :received_at
end
