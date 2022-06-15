class AddIndexToPrimaryConsentedToService < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def change
    remove_index :intakes, :primary_consented_to_service_at
    add_index :intakes, :primary_consented_to_service, algorithm: :concurrently
  end
end
