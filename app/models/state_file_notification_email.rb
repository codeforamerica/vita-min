# == Schema Information
#
# Table name: state_file_notification_emails
#
#  id         :bigint           not null, primary key
#  body       :string           not null
#  sent_at    :datetime
#  subject    :string           not null
#  to         :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class StateFileNotificationEmail < ApplicationRecord
  validates_presence_of :to
  validates_presence_of :body
  validates_presence_of :subject

  after_create_commit :deliver

  private

  def deliver
    StateFile::SendNotificationEmailJob.perform_later(id)
  end

end
