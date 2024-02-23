namespace :gyr_intake_sms_options do
  desc 'update currently in progress GYR intakes from early 2024 to be opted in to SMS'
  task update: [:environment] do
    UpdateGyrIntakeSmsOptionsJob.perform_now
  end
end