class AddAuthorizeSharingOfHealthInsuranceInfoToStateFileMdIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_md_intakes, :authorize_sharing_of_health_insurance_info, :integer, null: false, default: 0
  end
end
