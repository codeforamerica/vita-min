class CreateVitaPartnerZipCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :vita_partner_zip_codes do |t|
      t.references :vita_partner, null: false, foreign_key: true
      t.string :zip_code, null: false
      t.timestamps
    end
  end
end
