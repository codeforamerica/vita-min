namespace :client_messaging do
  desc 'send "still needs help" email to eligible clients'
  task send_still_needs_help_emails: [:environment] do
    SendStillNeedsHelpEmailsJob.perform_now
  end
end
