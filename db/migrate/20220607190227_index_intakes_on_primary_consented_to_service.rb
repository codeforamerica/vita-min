class IndexIntakesOnPrimaryConsentedToService < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def change
    add_index :intakes, :primary_consented_to_service, algorithm: :concurrently
  end
end
