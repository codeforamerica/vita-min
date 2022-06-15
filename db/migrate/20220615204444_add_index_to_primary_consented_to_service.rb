class AddIndexToPrimaryConsentedToService < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def change
    add_index :intakes, :primary_consented_to_service, algorithm: :concurrently
    safety_assured { remove_column :intakes, :primary_consented_to_service_at }
  end
end
