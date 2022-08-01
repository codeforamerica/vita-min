namespace :client_surveys do
  desc 'send completion surveys to eligible clients'
  task send_completion_surveys: [:environment] do
    AutomatedMessage::CtcExperienceSurvey.enqueue_surveys
    AutomatedMessage::CompletionSurvey.enqueue_surveys
  end

  desc 'send client in progress surveys to eligible clients'
  task send_client_in_progress_surveys: [:environment] do
    AutomatedMessage::InProgressSurvey.enqueue_surveys
  end
end
