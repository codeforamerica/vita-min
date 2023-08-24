class AddSpouseEmailAddressIndexToIntakes < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :intakes, :spouse_email_address, algorithm: :concurrently
  end
end
