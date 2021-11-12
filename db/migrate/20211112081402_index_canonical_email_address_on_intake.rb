class IndexCanonicalEmailAddressOnIntake < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :intakes, :canonical_email_address, algorithm: :concurrently
  end
end
