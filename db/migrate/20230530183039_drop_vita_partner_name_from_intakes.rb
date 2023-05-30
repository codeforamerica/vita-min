class DropVitaPartnerNameFromIntakes < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :intakes, :vita_partner_name, :string }
  end
end
