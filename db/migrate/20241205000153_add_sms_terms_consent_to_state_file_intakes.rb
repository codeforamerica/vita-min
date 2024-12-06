class AddSmsTermsConsentToStateFileIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :consented_to_sms_terms, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :consented_to_sms_terms, :integer, default: 0, null: false
    add_column :state_file_nc_intakes, :consented_to_sms_terms, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :consented_to_sms_terms, :integer, default: 0, null: false
    add_column :state_file_id_intakes, :consented_to_sms_terms, :integer, default: 0, null: false
    add_column :state_file_md_intakes, :consented_to_sms_terms, :integer, default: 0, null: false
  end
end
