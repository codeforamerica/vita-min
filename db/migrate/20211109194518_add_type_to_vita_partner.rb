class AddTypeToVitaPartner < ActiveRecord::Migration[6.0]
  def change
    add_column :vita_partners, :type, :string
  end
end
