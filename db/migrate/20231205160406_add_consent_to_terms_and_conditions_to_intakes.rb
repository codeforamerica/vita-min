class AddConsentToTermsAndConditionsToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :consented_to_terms_and_conditions, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :consented_to_terms_and_conditions, :integer, default: 0, null: false
  end
end
