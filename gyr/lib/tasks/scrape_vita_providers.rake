namespace :vita_providers do
  desc 'scrapes vita providers from IRS website'
  task scrape_vita_providers: [:environment] do
    service = ScrapeVitaProvidersJob.new
    service.perform_now
  end
end
