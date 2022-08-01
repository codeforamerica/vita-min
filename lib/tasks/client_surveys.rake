namespace :client_surveys do
  desc 'send client in progress surveys to eligible clients'
  task send_client_in_progress_surveys: [:environment] do
    AutomatedMessage::InProgressSurvey.enqueue_surveys
  end
end
