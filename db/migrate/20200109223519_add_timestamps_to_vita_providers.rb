class AddTimestampsToVitaProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :vita_providers, :created_at, :datetime
    add_column :vita_providers, :updated_at, :datetime
  end
end
