class RemoveVitaPartnerFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :vita_partner_id, :bigint
  end
end