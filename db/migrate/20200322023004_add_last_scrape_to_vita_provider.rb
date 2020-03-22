class AddLastScrapeToVitaProvider < ActiveRecord::Migration[5.2]
  def change
    add_reference :vita_providers, :last_scrape, foreign_key: { to_table: :provider_scrapes }
  end
end
