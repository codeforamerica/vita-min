class ScrapeVitaProvidersJob < ApplicationJob
  def perform
    irs_provider_listings = ScrapeVitaProvidersService.new.import
    scrape = ProviderScrape.get_recent_or_create
    before_scrape_listed_provider_count = VitaProvider.listed.count
    before_scrape_total_provider_count = VitaProvider.count

    irs_provider_listings.each do |provider_listing|
      scrape.handle_irs_provider_data(provider_listing)
    end

    scrape.archive_all_unscraped_providers

    <<~REPORT
        Finished updating all provider records!
        ---------------------------------------
        Total provider count before scraping: #{before_scrape_total_provider_count}
        Total provider count after scraping: #{VitaProvider.count}
        Listed provider count before scraping: #{before_scrape_listed_provider_count}
        Listed provider count after scraping: #{VitaProvider.listed.count}

        Newly created record count: #{scrape.created_count}
        Changed record count: #{scrape.changed_count}
        Newly archived record count: #{scrape.archived_count}
    REPORT
  end
end