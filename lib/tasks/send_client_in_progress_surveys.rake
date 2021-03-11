namespace :client_surveys do
  desc 'send client in progress surveys to eligible clients'
  task send_client_in_progress_surveys: [:environment] do
    Client.needs_in_progress_survey.each { |client| SendClientInProgressSurveyJob.perform_later(client) }
  end
end
