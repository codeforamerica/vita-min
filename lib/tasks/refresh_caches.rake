namespace :refresh_caches do
  desc 'Refresh caches for registered classes'
  task go: [:environment] do
    RefreshCachesJob.perform_later    
  end
end
