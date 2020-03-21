class AddArchivedToVitaProvider < ActiveRecord::Migration[5.2]
  def change
    add_column :vita_providers, :archived, :boolean, default: false, null: false
  end
end
