class AddConsentFieldsToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :primary_consented_to_service, :integer, default: 0, null: false
    add_column :intakes, :primary_consented_to_service_ip, :inet
    add_column :intakes, :primary_consented_to_service_at, :datetime
    add_column :intakes, :spouse_consented_to_service, :integer, default: 0, null: false
    add_column :intakes, :spouse_consented_to_service_ip, :inet
    add_column :intakes, :spouse_consented_to_service_at, :datetime
  end
end
