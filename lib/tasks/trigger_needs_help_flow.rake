namespace :needs_help_flow do
  desc 'send client in progress surveys to eligible clients'
  task init: [:environment] do
    StillNeedsHelpService.clients_who_still_may_need_help(intake_type: "Intake::GyrIntake").find_each do |client|
      StillNeedsHelpService.trigger_still_needs_help_flow(client)
    end
  end
end
