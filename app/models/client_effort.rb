# == Schema Information
#
# Table name: client_efforts
#
#  id              :bigint           not null, primary key
#  effort_type     :integer          not null
#  made_at         :datetime         not null
#  responded_to_at :datetime
#  response_type   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  intake_id       :bigint           not null
#  ticket_id       :bigint           not null
#
# Indexes
#
#  index_client_efforts_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#
class ClientEffort < ApplicationRecord
  belongs_to :intake

  enum effort_type: {
    consented: 0,
    completed_intake_questions: 1,
    uploaded_docs: 2,
    uploaded_requested_docs: 3,
    completed_full_intake: 4,
    sent_sms: 5,
    returned_to_intake: 6,
    sent_email: 7,
    emailed_support: 8,
    opened_support_chat: 9,
  }, _prefix: :effort_type
  enum response_type: {
    public_reply: 0,
    phone_call: 1,
    status_change: 2,
  }, _prefix: :response_type

  validates_presence_of :ticket_id
  validates_presence_of :made_at
  validates_presence_of :effort_type
end


