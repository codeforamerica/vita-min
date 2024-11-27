class AddHealthInsuranceFlagsToStateFileMdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :primary_did_not_have_health_insurance, :integer, null: false, default: 0
    add_column :state_file_md_intakes, :spouse_did_not_have_health_insurance, :integer, null: false, default: 0
    add_column :state_file_md_intakes, :had_hh_member_without_health_insurance, :integer, null: false, default: 0
    add_column :state_file_md_intakes, :authorize_sharing_of_health_insurance_info, :integer, null: false, default: 0
  end
end
