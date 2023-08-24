class AddPrimaryConsentedToServiceAtToClient < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def change
    add_column :clients, :consented_to_service_at, :datetime
    add_index :clients, :consented_to_service_at, algorithm: :concurrently
  end
end
