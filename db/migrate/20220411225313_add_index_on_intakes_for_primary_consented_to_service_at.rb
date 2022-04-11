class AddIndexOnIntakesForPrimaryConsentedToServiceAt < ActiveRecord::Migration[6.1]
  def change
    add_index :intakes, :primary_consented_to_service_at
  end
end
