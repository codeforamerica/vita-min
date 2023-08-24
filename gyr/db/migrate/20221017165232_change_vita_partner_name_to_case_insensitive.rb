class ChangeVitaPartnerNameToCaseInsensitive < ActiveRecord::Migration[7.0]
  def change
    safety_assured { change_column :vita_partners, :name, :citext }
  end
end
