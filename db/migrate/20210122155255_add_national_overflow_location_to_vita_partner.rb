class AddNationalOverflowLocationToVitaPartner < ActiveRecord::Migration[6.0]
  def change
    remove_column :vita_partners, :accepts_overflow, :boolean
    add_column :vita_partners, :national_overflow_location, :boolean, default: false
  end
end
