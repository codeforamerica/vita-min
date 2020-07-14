# == Schema Information
#
# Table name: client_efforts
#
#  id              :bigint           not null, primary key
#  effort_type     :string           not null
#  made_at         :datetime         not null
#  responded_to_at :datetime
#  response_type   :string
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
  EFFORT_TYPES = %w(
    consented
    completed_intake_questions
    uploaded_docs
    uploaded_requested_docs
    completed_full_intake
    sent_sms
    returned_to_intake
    sent_email
    emailed_support
    opened_support_chat
  ).freeze

  RESPONSE_TYPES = %w(
    public_reply
    phone_call
    status_change
  )

  belongs_to :intake

  validates_presence_of :ticket_id
  validates_presence_of :made_at
  validates_presence_of :effort_type

  validates :effort_type, inclusion: { in: EFFORT_TYPES }
  validates :response_type, allow_blank: true, inclusion: { in: RESPONSE_TYPES }
end


