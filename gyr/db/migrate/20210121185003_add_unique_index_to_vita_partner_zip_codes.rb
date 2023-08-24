class AddUniqueIndexToVitaPartnerZipCodes < ActiveRecord::Migration[6.0]
  def change
    add_index :vita_partner_zip_codes, [:zip_code], unique: true
  end
end
