class SendSurveyNotificationJob < ApplicationJob
  def perform
    p 'Perform, send notification ====='
  end

  def priority
    PRIORITY_LOW
  end

  # SendSurveyNotificationJob.set(wait_until: 15.seconds.from_now).perform_later
  # SendSurveyNotificationJob.set(wait_until: 15.seconds.from_now).perform_later()
end