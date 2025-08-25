class UserNotificationEmail < ApplicationRecord
  has_one :user_notification
  validates_presence_of :to
  validates_presence_of :body
  validates_presence_of :subject

  after_create_commit :deliver

  private

  def deliver
    SendUserNotificationEmailJob.perform_later(id)
  end
end
