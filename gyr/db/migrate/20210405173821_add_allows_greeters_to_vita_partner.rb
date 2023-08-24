class AddAllowsGreetersToVitaPartner < ActiveRecord::Migration[6.0]
  def change
    add_column :vita_partners, :allows_greeters, :boolean
  end
end
