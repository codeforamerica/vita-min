namespace :efile do
  desc "Periodic tasks for e-filing"
  task poll_and_get_acknowledgments: :environment do
    Efile::PollForAcknowledgmentsService.run
  end
end