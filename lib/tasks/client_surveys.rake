namespace :client_surveys do
  desc 'send completion surveys to eligible clients'
  task send_completion_surveys: [:environment] do
    SurveyMessages::CtcExperienceSurvey.enqueue_surveys(Time.current)
    SurveyMessages::GyrCompletionSurvey.enqueue_surveys(Time.current)
  end
end
