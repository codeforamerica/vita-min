class ScrapeVitaProvidersJob < ApplicationJob
  MIXPANEL_ROBOT_ID = "ScrapeVitaProvidersJob"

  def perform
    irs_provider_listings = ScrapeVitaProvidersService.new.import
    scrape = ProviderScrape.get_recent_or_create
    before_scrape_listed_provider_count = VitaProvider.listed.count
    before_scrape_total_provider_count = VitaProvider.count

    irs_provider_listings.each do |provider_listing|
      scrape.handle_irs_provider_data(provider_listing)
    end

    scrape.archive_all_unscraped_providers

    data = {
      total_provider_count_before: before_scrape_total_provider_count,
      total_provider_count_after: VitaProvider.count,
      listed_provider_count_before: before_scrape_listed_provider_count,
      listed_provider_count_after: VitaProvider.listed.count,
      new_provider_count: scrape.created_count,
      changed_provider_count: scrape.changed_count,
      archived_provider_count: scrape.archived_count,
    }

    MixpanelService.send_event(
      distinct_id: MIXPANEL_ROBOT_ID,
      event_name: "scrape_vita_providers",
      data: data,
    )

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
