class AddTimezoneToVitaPartner < ActiveRecord::Migration[6.0]
  def change
    add_column :vita_partners, :timezone, :string, default: "America/New_York"
  end
end
