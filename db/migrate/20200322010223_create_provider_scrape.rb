class CreateProviderScrape < ActiveRecord::Migration[5.2]
  def change
    create_table :provider_scrapes do |t|
      t.timestamps
      t.integer :archived_count, default: 0, null: false
      t.integer :created_count, default: 0, null: false
      t.integer :changed_count, default: 0, null: false
    end
  end
end
