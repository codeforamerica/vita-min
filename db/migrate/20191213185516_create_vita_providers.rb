class CreateVitaProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :vita_providers do |t|
      t.string :name
      t.string :irs_id, null: false, unique: true
      t.string :details
      t.st_point :coordinates, geographic: true
      t.string :dates
      t.string :hours
      t.string :languages
      t.string :appointment_info
    end
    add_index :vita_providers, :irs_id, unique: true
  end
end
