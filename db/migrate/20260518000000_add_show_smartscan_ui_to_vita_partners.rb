class AddShowSmartscanUiToVitaPartners < ActiveRecord::Migration[7.2]
  def change
    add_column :vita_partners, :show_smartscan_ui, :boolean
  end
end
