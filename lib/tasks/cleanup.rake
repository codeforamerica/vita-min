namespace :cleanup do
  desc 'Remove clients/intakes/etc that are not consented to service'
  task remove_unconsented_clients: [:environment] do
    RemoveUnconsentedClientsJob.perform_later
  end
end
