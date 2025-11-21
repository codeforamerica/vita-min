class RemoveZipcodeIndexingToPartner < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    remove_index :vita_partner_zip_codes, :zip_code
    add_index :vita_partner_zip_codes, :zip_code, algorithm: :concurrently
  end

  def down
    remove_index :vita_partner_zip_codes, :zip_code
    add_index :vita_partner_zip_codes, :zip_code, unique: true, algorithm: :concurrently
  end
end
