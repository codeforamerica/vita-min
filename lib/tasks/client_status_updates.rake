namespace :client_status_updates do
  desc 'send completion surveys to eligible clients'
  task send_completion_surveys: [:environment] do
    SurveyMessages::CtcExperienceSurvey.enqueue_surveys(Time.current)
    SurveyMessages::GyrCompletionSurvey.enqueue_surveys(Time.current)
  end

  desc 'send client in progress an automated message'
  task send_client_in_progress_automated_messages: [:environment] do
    AutomatedMessage::InProgress.enqueue_messages(Time.now)
  end
end
