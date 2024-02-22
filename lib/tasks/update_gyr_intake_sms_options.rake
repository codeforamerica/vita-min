namespace :gyr_intakes do
  desc 'update currently in progress GYR intakes from early 2024 to be opted in to SMS'
  task update_sms_options: [:environment] do
    UpdateGyrIntakeSmsOptionsJob.perform
  end
end