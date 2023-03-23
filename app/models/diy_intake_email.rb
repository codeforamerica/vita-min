# == Schema Information
#
# Table name: diy_intake_emails
#
#  id             :bigint           not null, primary key
#  mailgun_status :string           default("sending")
#  sent_at        :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  diy_intake_id  :bigint
#  message_id     :string
#
# Indexes
#
#  index_diy_intake_emails_on_diy_intake_id  (diy_intake_id)
#
class DiyIntakeEmail < ApplicationRecord
  belongs_to :diy_intake
end
